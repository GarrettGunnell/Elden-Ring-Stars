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
                float4x4 rotation;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            StructuredBuffer<StarData> _StarsBuffer;
            
            v2f vert(VertexData v, uint instanceID : SV_INSTANCEID) {
                v2f o;

                float hash = randValue(instanceID);

                float sizeMod = hash * 0.7f + 0.2f;

                float4 starPosition = _StarsBuffer[instanceID].position;

                float4 localPosition = v.vertex;
                localPosition *= sizeMod;
                localPosition = mul(_StarsBuffer[instanceID].rotation, localPosition);

                float4 worldPosition = localPosition + starPosition;

                o.vertex = UnityObjectToClipPos(worldPosition);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(_StarsBuffer[instanceID].rotation, normalize(v.normal));
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0.xyz) * 0.9f + 0.1f;

                return col * ndotl;
            }

            ENDCG
        }
    }
}