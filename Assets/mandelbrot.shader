Shader "FX/mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Area ("Area", vector) = (0, 0, 4, 4)
        _MaxIterations ("Max Iterations", Integer) = 1000
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _Area;
            int _MaxIterations;

            // cubic interpolation
            float3 cerp(float3 a, float3 b, float3 c, float t)
            {
                float s = 1. - t;
                return b + s*s*(a - b) + t*t*(c - b);
            }

            float3 get_color(float t)
            {
                const float3 q[5] = {
                    float3(43, 155, 193),
                    float3(173, 133, 187),
                    float3(234, 184, 59),
                    float3(161, 193, 31),
                    float3(43, 155, 193)
                };

                t = frac(t);
                float u = t * 4;
                int i = int(u);

                return float3(
                    lerp(q[i].x, q[i+1].x, frac(u)),
                    lerp(q[i].y, q[i+1].y, frac(u)),
                    lerp(q[i].z, q[i+1].z, frac(u))
                ) / 256;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 c = _Area.xy + (i.uv - .5)*_Area.zw;
                float2 z;
                float iter;
                for (iter = 0; iter < _MaxIterations; iter++) {
                    float xx = z.x*z.x;
                    float yy = z.y*z.y;
                    z = float2(
                        xx - yy,
                        2*z.x*z.y
                    ) + c;
                    if (4 < xx + yy) break;
                }
                for (uint i = 0; i < 2; i++) {
                    z = float2(
                        z.x*z.x - z.y*z.y,
                        2*z.x*z.y
                    ) + c;
                }

                if (_MaxIterations <= iter) {
                    return 0;
                }

                float smoothIter = float(iter)-log2(log(length(z)));
                return float4(get_color(32*smoothIter/_MaxIterations), 1.0);
            }
            ENDCG
        }
    }
}
