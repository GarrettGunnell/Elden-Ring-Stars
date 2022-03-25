using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : MonoBehaviour {
    public Shader bloomShader;

    [Range(0.0f, 10.0f)]
    public float threshold = 1.0f;

    [Range(0.0f, 1.0f)]
    public float softThreshold = 0.5f;

    private Material bloomMat;

    void Start() {
        bloomMat ??= new Material(bloomShader);
        bloomMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        bloomMat.SetFloat("_Threshold", threshold);
        bloomMat.SetFloat("_SoftThreshold", softThreshold);
        Graphics.Blit(source, destination, bloomMat);
    }
}
