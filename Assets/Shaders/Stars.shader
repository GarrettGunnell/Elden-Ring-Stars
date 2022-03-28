Shader "Unlit/Stars" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", Color) = (0, 0, 0)
        _EmissionDistanceModifier ("Emission Distance Modifier", Range(0.0, 1.0)) = 0.0
        _MinEmissionMod ("Minimum Emission Modifier", Range(0.0, 1.0)) = 0.0
        _MaxEmissionMod ("Maximum Emission Modifier", Range(0.0, 1.0)) = 1.0
        _MinSize ("Minimum Size", Range(0.0, 1.0)) = 0.0
        _MaxSize ("Maximum Size", Range(0.0, 2.0)) = 1.0
        _MaxOffset ("Maximum Positional Offset", Range(0.0, 1.0)) = 0.0
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
                float emissionMod : TEXCOORD3;
            };

            struct StarData {
                float4 position;
                float4x4 rotation;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Emission;
            float _EmissionDistanceModifier;
            float _MinSize, _MaxSize;
            float _MinEmissionMod, _MaxEmissionMod;
            float _MaxOffset;

            StructuredBuffer<StarData> _StarsBuffer;
            
            v2f vert(VertexData v, uint instanceID : SV_INSTANCEID) {
                v2f o;
                float4 starPosition = _StarsBuffer[instanceID].position;

                // Modify size
                float4 localPosition = v.vertex;
                float sizeMod = lerp(_MinSize, _MaxSize, randValue(instanceID));
                localPosition *= sizeMod;

                // Rotate
                localPosition = mul(_StarsBuffer[instanceID].rotation, localPosition);

                // Modify position
                float xOffset = lerp(-_MaxOffset, _MaxOffset, randValue(starPosition.x + localPosition.x));
                float yOffset = lerp(-_MaxOffset, _MaxOffset, randValue(starPosition.y + localPosition.y));
                float zOffset = lerp(-_MaxOffset, _MaxOffset, randValue(starPosition.z + localPosition.z));

                float3 offset = float3(xOffset, yOffset, zOffset);
                localPosition.xyz += offset;

                float4 worldPosition = localPosition + starPosition;

                o.vertex = UnityObjectToClipPos(worldPosition);
                o.worldPos = worldPosition;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(_StarsBuffer[instanceID].rotation, normalize(v.normal));
                o.emissionMod = lerp(_MinEmissionMod, _MaxEmissionMod, randValue(instanceID));
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);
                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0.xyz) * 0.5f + 0.5f;

                col *= ndotl;

                float viewDistance = length(_WorldSpaceCameraPos - i.worldPos);
                float emissionFactor = (_EmissionDistanceModifier / sqrt(log(2))) * viewDistance;
                emissionFactor = exp2(-emissionFactor);

                float4 maxEmission = float4(col.rgb + (_Emission - i.emissionMod), 1.0f);

                return lerp(maxEmission, col, emissionFactor * 0.95f);
            }

            ENDCG
        }
    }
}