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

    private Material bloomMat;

    void Start() {
        bloomMat ??= new Material(bloomShader);
        bloomMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        bloomMat.SetFloat("_Threshold", threshold);
        bloomMat.SetFloat("_SoftThreshold", softThreshold);
        bloomMat.SetInt("_KernelSize", blurKernelSize);

        RenderTexture bloomTargets = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, bloomTargets, bloomMat, 0);

        RenderTexture blurTarget1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(bloomTargets, blurTarget1, bloomMat, 1);

        RenderTexture blurTarget2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(blurTarget1, blurTarget2, bloomMat, 2);

        RenderTexture.ReleaseTemporary(bloomTargets);
        RenderTexture.ReleaseTemporary(blurTarget1);
        RenderTexture.ReleaseTemporary(blurTarget2);
        
        Graphics.Blit(blurTarget2, destination);
    }
}
