using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class explorer : MonoBehaviour {

    public Material mat;
    public Vector2 pos;
    public float scale;

    private Vector2 scaleVec = Vector2.zero;

    private void UpdateShader() {
        float aspectRatio = (float)Screen.width / (float)Screen.height;
        scaleVec = new Vector2(scale, scale);

        if (1f < aspectRatio) {
            scaleVec.x *= aspectRatio;
        } else {
            scaleVec.y /= aspectRatio;
        }

        mat.SetVector("_Area", new Vector4(pos.x, pos.y, scaleVec.x, scaleVec.y));
    }

    private void HandleInputs() {
        float wheelDelta = Input.mouseScrollDelta.y;
        if (1f <= Mathf.Abs(wheelDelta)) {
            float scaleFactor = Mathf.Pow(.92f, wheelDelta);

            Vector2 mouseUV = Vector2.Scale(
                Input.mousePosition,
                new Vector2(1/(float)Screen.width, 1/(float)Screen.height)
            );
            mouseUV -= new Vector2(.5f, .5f);

            pos -= Vector2.Scale(mouseUV * (1 - 1/scaleFactor), scaleVec);
            scale *= scaleFactor;
        }
    }

    void OnGUI() {
        HandleInputs();
    }

    void FixedUpdate() {
        UpdateShader();
    }
}
