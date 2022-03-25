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

            fixed4 fp(v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);

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

            fixed4 fp(v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 sum;

                int upper = ((_KernelSize - 1) / 2);
                int lower = -upper;

                for (int x = lower; x <= upper; ++x) {
                    sum += tex2D(_MainTex, i.uv + fixed2(_MainTex_TexelSize.x * x, 0.0f));
                }

                sum /= (float)_KernelSize;

                return fixed4(sum, 1.0f);
            }
            ENDCG
        }

        // Box Blur Pass 2
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float2 _MainTex_TexelSize;
            int _KernelSize;

            fixed4 fp(v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 sum;

                int upper = ((_KernelSize - 1) / 2);
                int lower = -upper;

                for (int y = lower; y <= upper; ++y) {
                    sum += tex2D(_MainTex, i.uv + fixed2(0.0f, _MainTex_TexelSize.y * y));
                }

                sum /= (float)_KernelSize;

                return fixed4(sum, 1.0f);
            }
            ENDCG
        }
    }
}