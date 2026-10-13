import hw1_common;

float2 to_object(float2 p, float3x3 world_to_obj) {
    return mul(world_to_obj, float3(p, 1.0)).xy;
}

bool point_in_poly(float2 p, StructuredBuffer<float2> points, int begin, int n) {
    int winding = 0;
    for (int i = 0; i < n; ++i) {
        float2 a = points[begin + i];
        float2 b = points[begin + (i + 1) % n];
        if ((a.y > p.y) == (b.y > p.y)) continue;
        float x = a.x + (p.y - a.y) * (b.x - a.x) / (b.y - a.y);
        if (x > p.x) winding += b.y > a.y ? 1 : -1;
    }
    return winding != 0;
}

bool point_segment(float2 p, float2 a, float2 b, float radius) {
    float2 ab = b - a;
    float h = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-12), 0.0, 1.0);
    return distance(p, a + h * ab) <= radius;
}

float2 bezier_eval(float2 p0, float2 p1, float2 p2, float t) {
    float u = 1.0 - t;
    return u * u * p0 + 2.0 * u * t * p1 + t * t * p2;
}

bool bezier_fill_hit(float2 p, StructuredBuffer<float2> points, int begin, int n, bool closed) {
    int count = closed ? max(0, (n - 2) / 2) : max(0, (n - 1) / 2);
    int winding = 0;
    for (int i = 0; i < count + (closed ? 1 : 0); ++i) {
        int i0, i1, i2;
        if (i < count) { i0 = 2 * i; i1 = i0 + 1; i2 = i0 + 2; }
        else { i0 = n - 2; i1 = n - 1; i2 = 0; }
        float2 p0 = points[begin + i0];
        float2 p1 = points[begin + i1];
        float2 p2 = points[begin + i2];
        float2 A = p0 - 2.0 * p1 + p2;
        float2 B = 2.0 * (p1 - p0);
        float a = A.y, b = B.y, c = p0.y - p.y;
        float roots[2];
        int nr = 0;
        if (abs(a) < 1e-7) {
            if (abs(b) > 1e-7) { roots[0] = -c / b; nr = 1; }
        } else {
            float disc = b * b - 4.0 * a * c;
            if (disc >= 0.0) {
                float sd = sqrt(disc);
                roots[0] = (-b - sd) / (2.0 * a);
                roots[1] = (-b + sd) / (2.0 * a);
                nr = disc < 1e-7 ? 1 : 2;
            }
        }
        for (int r = 0; r < nr; ++r) {
            float t = roots[r];
            // Half-open segments avoid double-counting shared endpoints.
            if (t < 0.0 || t >= 1.0) continue;
            float dy = 2.0 * a * t + b;
            if (abs(dy) < 1e-7) continue;
            float x = bezier_eval(p0, p1, p2, t).x;
            if (x > p.x) winding += dy > 0.0 ? 1 : -1;
        }
    }
    return winding != 0;
}

bool bezier_stroke_hit(float2 p, StructuredBuffer<float2> points, int begin, int n, bool closed, float radius) {
    int count = closed ? max(0, (n - 2) / 2) : max(0, (n - 1) / 2);
    float best = 1e30;
    for (int i = 0; i < count + (closed ? 1 : 0); ++i) {
        int i0, i1, i2;
        if (i < count) { i0 = 2 * i; i1 = i0 + 1; i2 = i0 + 2; }
        else { i0 = n - 2; i1 = n - 1; i2 = 0; }
        float2 p0 = points[begin + i0];
        float2 p1 = points[begin + i1];
        float2 p2 = points[begin + i2];
        float2 A = p0 - 2.0 * p1 + p2;
        float2 B = 2.0 * (p1 - p0);
        float2 C = p0 - p;
        float3 roots;
        int nr = solve_cubic(2.0 * dot(A, A), 3.0 * dot(A, B), dot(B, B) + 2.0 * dot(A, C), dot(B, C), roots);
        float2 q0 = bezier_eval(p0, p1, p2, 0.0);
        float2 q1 = bezier_eval(p0, p1, p2, 1.0);
        best = min(best, min(distance(p, q0), distance(p, q1)));
        for (int r = 0; r < nr; ++r) {
            float t = roots[r];
            if (t >= 0.0 && t <= 1.0) best = min(best, distance(p, bezier_eval(p0, p1, p2, t)));
        }
    }
    return best <= radius;
}

void render_pixel(uint2 tid, uint width, uint height,
                  uniform float3 background, uniform int samples_per_axis,
                  StructuredBuffer<Shape> shapes, uniform int num_shapes,
                  StructuredBuffer<Circle> circles, StructuredBuffer<Polyline> polylines,
                  StructuredBuffer<QuadraticBezier> quadratic_beziers,
                  StructuredBuffer<float2> points, RWTexture2D<float4> image,
                  uniform bool antialias, uniform bool alpha_blend, uniform bool bezier_enabled) {
    if (tid.x >= width || tid.y >= height) return;
    int N = antialias ? clamp(samples_per_axis, 1, 16) : 1;
    float3 pixel = float3(0.0);
    for (int sy = 0; sy < N; ++sy) {
        for (int sx = 0; sx < N; ++sx) {
            float2 p = float2(tid.x + (sx + 0.5) / N, height - (tid.y + (sy + 0.5) / N));
            float3 sample_color = float3(0.0);
            float transmittance = 1.0;
            for (int i = 0; i < num_shapes; ++i) {
                Shape s = shapes[i];
                float2 po = to_object(p, s.world_to_obj);
                bool fill_hit = false;
                bool stroke_hit = false;
                float4 fill = s.fill_rgba;
                float4 stroke = s.stroke_rgba;
                if (s.type == ShapeType::Circle) {
                    Circle c = circles[s.index];
                    float d = distance(po, c.center);
                    fill_hit = s.use_fill && d <= c.radius;
                    stroke_hit = s.use_stroke && abs(d - c.radius) <= s.stroke_width * 0.5;
                } else if (s.type == ShapeType::Polyline) {
                    Polyline pl = polylines[s.index];
                    int begin = pl.pts_begin, n = pl.pts_end - pl.pts_begin;
                    fill_hit = s.use_fill && pl.closed && n >= 3 && point_in_poly(po, points, begin, n);
                    if (s.use_stroke && n >= 2) {
                        int edges = pl.closed ? n : n - 1;
                        for (int j = 0; j < edges && !stroke_hit; ++j)
                            stroke_hit = point_segment(po, points[begin + j], points[begin + (j + 1) % n], s.stroke_width * 0.5);
                    }
                } else if (s.type == ShapeType::QuadraticBezier && bezier_enabled) {
                    QuadraticBezier bz = quadratic_beziers[s.index];
                    int begin = bz.pts_begin, n = bz.pts_end - bz.pts_begin;
                    fill_hit = s.use_fill && bz.closed && n >= 3 && bezier_fill_hit(po, points, begin, n, bz.closed);
                    stroke_hit = s.use_stroke && n >= 3 && bezier_stroke_hit(po, points, begin, n, bz.closed, s.stroke_width * 0.5);
                }
                // Fill is behind the outline; composite both as separate layers.
                if (fill_hit) {
                    float a = alpha_blend ? saturate(fill.a) : 1.0;
                    sample_color += transmittance * a * fill.rgb;
                    transmittance *= 1.0 - a;
                }
                if (stroke_hit) {
                    float a = alpha_blend ? saturate(stroke.a) : 1.0;
                    sample_color += transmittance * a * stroke.rgb;
                    transmittance *= 1.0 - a;
                }
                if (transmittance < 1e-5) break;
            }
            sample_color += transmittance * background;
            pixel += sample_color / float(N * N);
        }
    }
    image[tid] = float4(pixel, 1.0);
}
