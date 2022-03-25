Shader "Hidden/Bloom" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
        ENDCG

        // Filter Pixels
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _Threshold, _SoftThreshold;

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                half brightness = max(col.r, max(col.g, col.b));
                half knee = _Threshold * _SoftThreshold;
                half soft = brightness - _Threshold + knee;
                soft = clamp(soft, 0, 2 * knee);
                soft = soft * soft / (4 * knee * 0.00001);
                half contribution = max(soft, brightness - _Threshold);
                contribution /= max(contribution, 0.00001);

                return col * contribution;
            }
            ENDCG
        }

        // Box Blur Pass 1
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float2 _MainTex_TexelSize;
            int _KernelSize;
            float _BlurSpread;

            #define TWO_PI  6.28319
            #define E       2.71828



            float gaussian(int x, int y) {
                float sigmaSqu = _BlurSpread * _BlurSpread;
                return (1.0f / sqrt(TWO_PI * sigmaSqu)) * pow(E, -((x * x) + (y * y)) / (2.0f * sigmaSqu));
            }

            float4 fp(v2f i) : SV_Target {
                float3 col;
                float kernelSum;

                int upper = ((_KernelSize - 1) / 2);
                int lower = -upper;

                for (int x = lower; x <= upper; ++x) {
                    for (int y = lower; y <= upper; ++y) {
                        float gauss = gaussian(x, y);
                        kernelSum += gauss;

                        fixed2 offset = fixed2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
                        col += gauss * tex2D(_MainTex, i.uv + offset).rgb;
                    }
                }

                col /= kernelSum;

                return float4(col, 1.0f);
            }
            ENDCG
        }

        // Additive Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            sampler2D _OriginalTex;

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float4 originalCol = tex2D(_OriginalTex, i.uv);

                return col + originalCol;
            }
            ENDCG
        }
    }
}