Shader "Unlit/Stars" {
    Properties {
        
    }

    SubShader {
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

            StructuredBuffer<StarData> _StarsBuffer;
            
            v2f vert(VertexData v, uint instanceID : SV_INSTANCEID) {
                v2f o;

                float hash = randValue(instanceID);

                float4 starPosition = _StarsBuffer[instanceID].position;

                float4 worldPosition = (v.vertex) + starPosition;

                o.vertex = UnityObjectToClipPos(worldPosition);
                o.uv = v.uv;
                o.normal = normalize(v.normal);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0.xyz);

                return ndotl;
            }

            ENDCG
        }
    }
}