Shader "Unlit/Stars" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", Color) = (0, 0, 0)
        _EmissionDistanceModifier ("Emission Distance Modifier", Range(0.0, 1.0)) = 0.0
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
                float4 worldPos : TEXCOORD2;
            };

            struct StarData {
                float4 position;
                float4x4 rotation;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Emission;
            float _EmissionDistanceModifier;

            StructuredBuffer<StarData> _StarsBuffer;
            
            v2f vert(VertexData v, uint instanceID : SV_INSTANCEID) {
                v2f o;
                float4 starPosition = _StarsBuffer[instanceID].position;

                // Modify size
                float4 localPosition = v.vertex;
                localPosition *= randValue(instanceID) * 0.7f + 0.2f;

                // Modify position
                float xOffset = randValue(starPosition.x + localPosition.x) * 2.0f - 1.0f;
                float yOffset = randValue(starPosition.y + localPosition.y) * 2.0f - 1.0f;
                float zOffset = randValue(starPosition.z + localPosition.z) * 2.0f - 1.0f;

                float3 offset = float3(xOffset, yOffset, zOffset) * 0.2f;
                localPosition.xyz += offset;

                // Rotate
                localPosition = mul(_StarsBuffer[instanceID].rotation, localPosition);

                float4 worldPosition = localPosition + starPosition;

                o.vertex = UnityObjectToClipPos(worldPosition);
                o.worldPos = worldPosition;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(_StarsBuffer[instanceID].rotation, normalize(v.normal));
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0.xyz) * 0.5f + 0.5f;

                col *= ndotl;

                float viewDistance = length(_WorldSpaceCameraPos - i.worldPos);
                float emissionFactor = (_EmissionDistanceModifier / sqrt(log(2))) * viewDistance;
                emissionFactor = exp2(-emissionFactor);

                float4 maxEmission = float4(col.rgb + _Emission, 1.0f);

                return lerp(maxEmission, col, emissionFactor * 0.95f);
            }

            ENDCG
        }
    }
}