using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class TutorialTrigger : ActivatableObject
{
    [Space(10)]
    [SerializeField]
    private string message;
    private TextMeshProUGUI textObj;
    [SerializeField]
    private bool showOnce = true;
    private bool alreadyShown = false;
    private enum RequiredInput
    {
        NONE = 0,
        CONFIRM = 5,
        WASD = 10,
        SNEAK = 20,
        SPRINT = 30,
        THROW = 40,
        TRAP = 50,
    }
    [SerializeField]
    private RequiredInput input;
    private Controls inputActions;
    private InputAction action;
    private bool promptActive = false;
    private Canvas canvas;

    protected override void Awake()
    {
        canvas = GetComponentInChildren<Canvas>(true);
        textObj = GetComponentInChildren<TextMeshProUGUI>(true);
        textObj.text = message;

        inputActions = new Controls();
        switch (input) 
        {
            case RequiredInput.CONFIRM:
                action = inputActions.UI.Confirm; break;
            case RequiredInput.WASD:
                action = inputActions.Movement.Move; break;
            case RequiredInput.SNEAK:
                action = inputActions.Movement.Sneak; break;
            case RequiredInput.SPRINT:
                action = inputActions.Movement.Sprint; break;
            case RequiredInput.THROW:
                action = inputActions.Mouse.LeftClick; break;
            case RequiredInput.TRAP:
                action = inputActions.Mouse.RightClick; break;
            case RequiredInput.NONE:
            default:
                Debug.Log("No Required Input specified"); break;
        }
        FindObjectOfType<UIController>().gamePause += OnPause;
    }

    protected override void Start()
    {
    }

    private void Update()
    {
        if(promptActive)
        {
            if(action.WasPerformedThisFrame())
            {
                HidePrompt();
            }
        }
    }

    public override void Activate()
    {
        alreadyShown = true;
    }

    public override void LoadData(GameData data)
    {
        base.LoadData(data);
        if (data.activatableObjectDataDictionary.ContainsKey(id))
        {
            alreadyShown = data.activatableObjectDataDictionary[id].hasBeenActivated;
        }
    }

    private void ShowPrompt()
    {
        if(showOnce && alreadyShown) { return; }
        action.Enable();
        promptActive = true;
        hasBeenActivated = true;
        alreadyShown = true;
        canvas.gameObject.SetActive(true);
    }
    private void HidePrompt()
    {
        action.Disable();
        promptActive = false;
        canvas.gameObject.SetActive(false);
    }
    protected override void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 3 && !promptActive)
        {
            ShowPrompt();
        }
    }

    private void OnPause(bool val)
    {
        if (val && promptActive)
        {
            canvas.gameObject.SetActive(true);
        }
        else
        {
            canvas.gameObject.SetActive(false);
        }
    }
}
