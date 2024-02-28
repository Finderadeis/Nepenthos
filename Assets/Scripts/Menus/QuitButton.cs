using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class QuitButton : MonoBehaviour
{
    public void OnQuit()
    {
#if UNITY_EDITOR
        EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
