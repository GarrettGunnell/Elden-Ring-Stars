using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : MonoBehaviour {
    public Shader bloomShader;

    [Range(0.0f, 10.0f)]
    public float threshold = 1.0f;

    [Range(0.0f, 1.0f)]
    public float softThreshold = 0.5f;

    [Range(1, 10)]
    public int blurKernelSize = 3;
    
    [Range(1.0f, 50.0f)]
    public float blurSpread = 5;

    private Material bloomMat;

    void Start() {
        bloomMat ??= new Material(bloomShader);
        bloomMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        bloomMat.SetFloat("_Threshold", threshold);
        bloomMat.SetFloat("_SoftThreshold", softThreshold);
        bloomMat.SetInt("_KernelSize", blurKernelSize);
        bloomMat.SetFloat("_BlurSpread", blurSpread);
        bloomMat.SetTexture("_OriginalTex", source);

        RenderTexture luminanceTarget = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, luminanceTarget, bloomMat, 0);

        RenderTexture blurTarget = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(luminanceTarget, blurTarget, bloomMat, 1);

        RenderTexture blurTarget2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(blurTarget, blurTarget2, bloomMat, 1);

        RenderTexture.ReleaseTemporary(luminanceTarget);
        RenderTexture.ReleaseTemporary(blurTarget);
        RenderTexture.ReleaseTemporary(blurTarget2);
        
        Graphics.Blit(blurTarget, destination, bloomMat, 2);
    }
}
