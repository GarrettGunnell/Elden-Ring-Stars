Shader "Hidden/Bloom" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;

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

        // Box Downsample
        Pass {
            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            float3 Sample(float2 uv) {
                return tex2D(_MainTex, uv).rgb;
            }

            float3 SampleBox(float2 uv, float delta) {
                float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
                float3 s = Sample(uv + o.xy) + Sample(uv + o.zy) + Sample(uv + o.xw) + Sample(uv + o.zw);

                return s * 0.25f;
            }

            float4 fp(v2f i) : SV_TARGET {
                return float4(SampleBox(i.uv, 1.0f), 1.0f);
            }
            ENDCG
        }

        // Box Upsample
        Pass {
            CGPROGRAM
            #pragma vertex vp 
            #pragma fragment fp

            float3 Sample(float2 uv) {
                return tex2D(_MainTex, uv).rgb;
            }

            float3 SampleBox(float2 uv, float delta) {
                float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
                float3 s = Sample(uv + o.xy) + Sample(uv + o.zy) + Sample(uv + o.xw) + Sample(uv + o.zw);

                return s * 0.25f;
            }

            float4 fp(v2f i) : SV_TARGET {
                return float4(SampleBox(i.uv, 0.5f), 1.0f);
            }
            ENDCG
        }
/*
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
        }*/
    }
}