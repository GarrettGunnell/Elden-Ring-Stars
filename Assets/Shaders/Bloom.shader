Shader "Hidden/Bloom" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold ("Threshold", Range(0.0, 10.0)) = 1.0
        _SoftThreshold ("Soft Threshold", Range(0.0, 1.0)) = 0.5
    }

    SubShader {

        // Filter Pixels
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
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


    }
}