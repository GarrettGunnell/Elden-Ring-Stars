Shader "Unlit/Stars" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {
        Zwrite On

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 4.5

            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            #include "../Resources/Random.cginc"

            struct VertexData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            struct StarData {
                float4 position;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            StructuredBuffer<StarData> _StarsBuffer;
            
            v2f vert(VertexData v, uint instanceID : SV_INSTANCEID) {
                v2f o;

                float hash = randValue(instanceID);

                float4 starPosition = _StarsBuffer[instanceID].position;

                float4 worldPosition = (v.vertex) + starPosition;

                o.vertex = UnityObjectToClipPos(worldPosition);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalize(v.normal);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0.xyz);

                return col * ndotl;
            }

            ENDCG
        }
    }
}