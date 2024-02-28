Shader"Shader/FullscreenBackgroundBlur"
{
    Properties
    {
        _Tint("Tint", Color) = (0.1932338, 0, 0.9339623, 0)
        _Quality("Quality", Float) = 0
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            // RenderType: <None>
            // Queue: <None>
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalFullscreenSubTarget"
        }
        Pass
        {
Name"DrawProcedural"
        
        // Render State
        Cull
Off
        Blend
Off
        ZTest
Off
        ZWrite
Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        // #pragma enable_d3d11_debug_symbols
        
        /* WARNING: $splice Could not find named fragment 'DotsInstancingOptions' */
        /* WARNING: $splice Could not find named fragment 'HybridV1InjectedBuiltinProperties' */
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
#define FULLSCREEN_SHADERGRAPH
        
        // Defines
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_VERTEXID
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
        
        // Force depth texture because we need it for almost every nodes
        // TODO: dependency system that triggers this define from position or view direction usage
#define REQUIRE_DEPTH_TEXTURE
#define REQUIRE_NORMAL_TEXTURE
        
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DRAWPROCEDURAL
#define REQUIRE_OPAQUE_TEXTURE
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
struct Attributes
{
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
#endif
    uint vertexID : VERTEXID_SEMANTIC;
};
struct SurfaceDescriptionInputs
{
    float2 NDCPosition;
    float2 PixelPosition;
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0;
    float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
struct VertexDescriptionInputs
{
};
struct PackedVaryings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0 : INTERP0;
    float4 texCoord1 : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
        
PackedVaryings PackVaryings(Varyings input)
{
    PackedVaryings output;
    ZERO_INITIALIZE(PackedVaryings, output);
    output.positionCS = input.positionCS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
Varyings UnpackVaryings(PackedVaryings input)
{
    Varyings output;
    output.positionCS = input.positionCS;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
float4 _Tint;
float _Quality;
        CBUFFER_END
        
        
        // Object and Global properties
float _FlipY;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}
        
void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}
        
void Unity_SceneColor_float(float4 UV, out float3 Out)
{
    Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
}
        
void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}
        
void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
{
    Out = A / B;
}
        
void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
    Out = A * B;
}
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        // GraphVertex: <None>
        
        // Custom interpolators, pre surface
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreSurface' */
        
        // Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};
     
// FragFunction1
SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    float4 _Property_b63201cc596841f09246b91ac356fb46_Out_0_Vector4 = _Tint;
    float4 _ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
    float Slider_a369f4e9a0f94d56a29ab42b7627b29c = 0.00414;
    float _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float;
    Unity_Multiply_float_float(Slider_a369f4e9a0f94d56a29ab42b7627b29c, -1, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _Vector2_fbb299ba30184501a7c5cf40a8bdc4a3_Out_0_Vector2 = float2(_Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float, 0);
    float2 _TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_fbb299ba30184501a7c5cf40a8bdc4a3_Out_0_Vector2, _TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2);
    float3 _SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2, 0.0, 1.0)), _SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3);
    float2 _Vector2_ca0e135483bc48a1ac71c5ae3a6703fc_Out_0_Vector2 = float2(_Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_ca0e135483bc48a1ac71c5ae3a6703fc_Out_0_Vector2, _TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2);
    float3 _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2, 0.0, 1.0)), _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3);
    float3 _Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3;
    Unity_Add_float3(_SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3, _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3, _Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3);
    float2 _Vector2_c51aeebeaceb4e39a9c9e40ca9f1ebea_Out_0_Vector2 = float2(0, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_c51aeebeaceb4e39a9c9e40ca9f1ebea_Out_0_Vector2, _TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2);
    float3 _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2, 0.0, 1.0)), _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3);
    float3 _Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3;
    Unity_Add_float3(_Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3, _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3, _Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3);
    float2 _Vector2_1c1070e5029d4ffba2f4716804e23786_Out_0_Vector2 = float2(Slider_a369f4e9a0f94d56a29ab42b7627b29c, 0);
    float2 _TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_1c1070e5029d4ffba2f4716804e23786_Out_0_Vector2, _TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2);
    float3 _SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2, 0.0, 1.0)), _SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3);
    float2 _Vector2_9904abb66b5f42f5abc7ec26df044b17_Out_0_Vector2 = float2(Slider_a369f4e9a0f94d56a29ab42b7627b29c, Slider_a369f4e9a0f94d56a29ab42b7627b29c);
    float2 _TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_9904abb66b5f42f5abc7ec26df044b17_Out_0_Vector2, _TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2);
    float3 _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2, 0.0, 1.0)), _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3);
    float3 _Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3;
    Unity_Add_float3(_SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3, _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3, _Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3);
    float2 _Vector2_ccc0b1a68e704d708b62b6c9aa6e282c_Out_0_Vector2 = float2(0, Slider_a369f4e9a0f94d56a29ab42b7627b29c);
    float2 _TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_ccc0b1a68e704d708b62b6c9aa6e282c_Out_0_Vector2, _TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2);
    float3 _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2, 0.0, 1.0)), _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3);
    float3 _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3;
    Unity_Add_float3(_Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3, _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3, _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3);
    float3 _Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3;
    Unity_Add_float3(_Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3, _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3, _Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3);
    float3 _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3;
    Unity_Divide_float3(_Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3, float3(6, 6, 6), _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3);
    float3 _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3;
    Unity_Multiply_float3_float3((_Property_b63201cc596841f09246b91ac356fb46_Out_0_Vector4.xyz), _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3, _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3);
    surface.BaseColor = _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3;
    
    
//    float gaussian
//    (
//    int x)
//{
//        float sigmaSqu = _Spread * _Spread;
//        return (1 / sqrt(TWO_PI * sigmaSqu)) * pow(E, -(x * x) / (2 * sigmaSqu));
//    }
//    float4 frag_horizontal
//    (v2fi):
//    SV_Target
//{
//        float3 col = float3(0.0f, 0.0f, 0.0f);
//        float gridSum = 0.0f;

//        int upper = ((_GridSize - 1) / 2);
//        int lower = -upper;

//        for (int x = lower; x <= upper; ++x)
//        {
//            float gauss = gaussian(x);
//            gridSum += gauss;
//            float2 uv = i.uv + float2(_MainTex_TexelSize.x * x, 0.0f);
//            col += gauss * tex2D(_MainTex, uv).xyz;
//        }

//        col /= gridSum;
//        return float4(col, 1.0f);
//    }
 //   float4 frag_vertical
 //   (v2fi):
 //   SV_Target
	//{
 //       float3 col = float3(0.0f, 0.0f, 0.0f);
 //       float gridSum = 0.0f;

 //       int upper = ((_GridSize - 1) / 2);
 //       int lower = -upper;

 //       for (int y = lower; y <= upper; ++y)
 //       {
 //           float gauss = gaussian(y);
 //           gridSum += gauss;
 //           float2 uv = i.uv + float2(0.0f, _MainTex_TexelSize.y * y);
 //           col += gauss * tex2D(_MainTex, uv).xyz;
 //       }

 //       col /= gridSum;
 //       return float4(col, 1.0f);
 //   }
    
    //SurfaceDescription surface;
    //const float2 inputUvs = IN.NDCPosition.xy;
    //const float4 inputColor = Unity_Universal_SampleBuffer_BlitSource_float(inputUvs);
 
    //// Insert your own code, modifying inputColor
    //float4 outputColor = float4(inputColor.r, inputColor.g, inputColor.b, 1);
 
    //surface.BaseColor = outputColor.xyz;
    //surface.Alpha = 1;
    float4 uv = IN.NDCPosition.xy;
    float4 inputColor = Unity_Universal_SampleBuffer_BlitSource_float(uv);
    
    
    float3 col = float3(0, 0, 0);
    float gridSum = 0f;
    int upper = ((_GridSize - 1) / 2);
    int lower = -upper;

    for (int y = lower; y <= upper; ++y)
    {
        float gauss = gaussian(y);
        gridSum += gauss;
        float2 uv = i.uv + float2(0.0f, _MainTex_TexelSize.y * y);
        col += gauss * tex2D(_MainTex, uv).xyz;
    }

    col /= gridSum;
    
    surface.BaseColor = (1, 1, 1, 1);
    surface.Alpha = 0.5;
    return surface;
}
        
        // --------------------------------------------------
        // Build Graph Inputs
        
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
    float3 normalWS = SHADERGRAPH_SAMPLE_SCENE_NORMAL(input.texCoord0.xy);
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
        
        
        
        
    float3 viewDirWS = normalize(input.texCoord1.xyz);
    float linearDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(input.texCoord0.xy), _ZBufferParams);
    float3 cameraForward = -UNITY_MATRIX_V[2].xyz;
    float camearDistance = linearDepth / dot(viewDirWS, cameraForward);
    float3 positionWS = viewDirWS * camearDistance + GetCameraPositionWS();
        
        
    output.NDCPosition = input.texCoord0.xy;
        
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
    return output;
}
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenCommon.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenDrawProcedural.hlsl"
        
        ENDHLSL
        }
        Pass
        {
Name"Blit"
        
        // Render State
        Cull
Off
        Blend
Off
        ZTest
Off
        ZWrite
Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        // #pragma enable_d3d11_debug_symbols
        
        /* WARNING: $splice Could not find named fragment 'DotsInstancingOptions' */
        /* WARNING: $splice Could not find named fragment 'HybridV1InjectedBuiltinProperties' */
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
#define FULLSCREEN_SHADERGRAPH
        
        // Defines
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_VERTEXID
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
        
        // Force depth texture because we need it for almost every nodes
        // TODO: dependency system that triggers this define from position or view direction usage
#define REQUIRE_DEPTH_TEXTURE
#define REQUIRE_NORMAL_TEXTURE
        
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_BLIT
#define REQUIRE_OPAQUE_TEXTURE
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
struct Attributes
{
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
#endif
    uint vertexID : VERTEXID_SEMANTIC;
    float3 positionOS : POSITION;
};
struct SurfaceDescriptionInputs
{
    float2 NDCPosition;
    float2 PixelPosition;
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0;
    float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
struct VertexDescriptionInputs
{
};
struct PackedVaryings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0 : INTERP0;
    float4 texCoord1 : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
        
PackedVaryings PackVaryings(Varyings input)
{
    PackedVaryings output;
    ZERO_INITIALIZE(PackedVaryings, output);
    output.positionCS = input.positionCS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
Varyings UnpackVaryings(PackedVaryings input)
{
    Varyings output;
    output.positionCS = input.positionCS;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
float4 _Tint;
float _Quality;
        CBUFFER_END
        
        
        // Object and Global properties
float _FlipY;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}
        
void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}
        
void Unity_SceneColor_float(float4 UV, out float3 Out)
{
    Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
}
        
void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}
        
void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
{
    Out = A / B;
}
        
void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
    Out = A * B;
}
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        // GraphVertex: <None>
        
        // Custom interpolators, pre surface
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreSurface' */
        
        // Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};


// FragFunction 2
        
SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    float4 _Property_b63201cc596841f09246b91ac356fb46_Out_0_Vector4 = _Tint;
    float4 _ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
    float Slider_a369f4e9a0f94d56a29ab42b7627b29c = 0.00414;
    float _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float;
    Unity_Multiply_float_float(Slider_a369f4e9a0f94d56a29ab42b7627b29c, -1, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _Vector2_fbb299ba30184501a7c5cf40a8bdc4a3_Out_0_Vector2 = float2(_Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float, 0);
    float2 _TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_fbb299ba30184501a7c5cf40a8bdc4a3_Out_0_Vector2, _TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2);
    float3 _SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_361edb882cd445e3b2dea4d10bf14f12_Out_3_Vector2, 0.0, 1.0)), _SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3);
    float2 _Vector2_ca0e135483bc48a1ac71c5ae3a6703fc_Out_0_Vector2 = float2(_Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_ca0e135483bc48a1ac71c5ae3a6703fc_Out_0_Vector2, _TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2);
    float3 _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_4f905ce794d64fddb07091d5217c63d0_Out_3_Vector2, 0.0, 1.0)), _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3);
    float3 _Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3;
    Unity_Add_float3(_SceneColor_2d051944c1fc4b759ec44d547c789bee_Out_1_Vector3, _SceneColor_aafa597df8b34108a23ce04f9de6795a_Out_1_Vector3, _Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3);
    float2 _Vector2_c51aeebeaceb4e39a9c9e40ca9f1ebea_Out_0_Vector2 = float2(0, _Multiply_80a6ae2ebf984aec83a4e223eebf939f_Out_2_Float);
    float2 _TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_c51aeebeaceb4e39a9c9e40ca9f1ebea_Out_0_Vector2, _TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2);
    float3 _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_a5a7a9f4b08a40f6baa24ebd0364e85d_Out_3_Vector2, 0.0, 1.0)), _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3);
    float3 _Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3;
    Unity_Add_float3(_Add_99bc84e7e3e241a8b11d89df238c00f7_Out_2_Vector3, _SceneColor_c86c207e95bc4143bf0bd73343bb4b62_Out_1_Vector3, _Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3);
    float2 _Vector2_1c1070e5029d4ffba2f4716804e23786_Out_0_Vector2 = float2(Slider_a369f4e9a0f94d56a29ab42b7627b29c, 0);
    float2 _TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_1c1070e5029d4ffba2f4716804e23786_Out_0_Vector2, _TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2);
    float3 _SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_a2c7bb2a12d74b4e9e1131c7e1348267_Out_3_Vector2, 0.0, 1.0)), _SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3);
    float2 _Vector2_9904abb66b5f42f5abc7ec26df044b17_Out_0_Vector2 = float2(Slider_a369f4e9a0f94d56a29ab42b7627b29c, Slider_a369f4e9a0f94d56a29ab42b7627b29c);
    float2 _TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_9904abb66b5f42f5abc7ec26df044b17_Out_0_Vector2, _TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2);
    float3 _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_0f23ddafb9f64034801fc669dc1bc55b_Out_3_Vector2, 0.0, 1.0)), _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3);
    float3 _Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3;
    Unity_Add_float3(_SceneColor_9cb27973d2b143dda464ce763a9e8bb4_Out_1_Vector3, _SceneColor_bef65f7ac25c46fbac198b2bd5891cec_Out_1_Vector3, _Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3);
    float2 _Vector2_ccc0b1a68e704d708b62b6c9aa6e282c_Out_0_Vector2 = float2(0, Slider_a369f4e9a0f94d56a29ab42b7627b29c);
    float2 _TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2;
    Unity_TilingAndOffset_float((_ScreenPosition_565332b8c2ca4a68a515565dba35a34e_Out_0_Vector4.xy), float2(1, 1), _Vector2_ccc0b1a68e704d708b62b6c9aa6e282c_Out_0_Vector2, _TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2);
    float3 _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3;
    Unity_SceneColor_float((float4(_TilingAndOffset_2aefde2d8ded46e3b573b916679a9b03_Out_3_Vector2, 0.0, 1.0)), _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3);
    float3 _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3;
    Unity_Add_float3(_Add_d803c7e0616d4ac7a835e9e3de21f762_Out_2_Vector3, _SceneColor_7f0ecacbb45c45eeb388e60a4828dcae_Out_1_Vector3, _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3);
    float3 _Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3;
    Unity_Add_float3(_Add_a7a71eef1cfe4656aa820cfeabd9132a_Out_2_Vector3, _Add_6230e0c5cd6047f2ace3d4218aca529b_Out_2_Vector3, _Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3);
    float3 _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3;
    Unity_Divide_float3(_Add_d756b4c222fb43f19ca5e9f12a4fb025_Out_2_Vector3, float3(6, 6, 6), _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3);
    float3 _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3;
    Unity_Multiply_float3_float3((_Property_b63201cc596841f09246b91ac356fb46_Out_0_Vector4.xyz), _Divide_9ef35710cbfe4d109b42a5d512a4d255_Out_2_Vector3, _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3);
    surface.BaseColor = _Multiply_79df6c28097a46b287ddd30f0afc3147_Out_2_Vector3;
    surface.Alpha = 0.5;
    return surface;
}
        
        // --------------------------------------------------
        // Build Graph Inputs
        
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
    float3 normalWS = SHADERGRAPH_SAMPLE_SCENE_NORMAL(input.texCoord0.xy);
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
        
        
        
        
    float3 viewDirWS = normalize(input.texCoord1.xyz);
    float linearDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(input.texCoord0.xy), _ZBufferParams);
    float3 cameraForward = -UNITY_MATRIX_V[2].xyz;
    float camearDistance = linearDepth / dot(viewDirWS, cameraForward);
    float3 positionWS = viewDirWS * camearDistance + GetCameraPositionWS();
        
        
    output.NDCPosition = input.texCoord0.xy;
        
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
    return output;
}
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenCommon.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenBlit.hlsl"
        
        ENDHLSL
        }
    }
CustomEditor"UnityEditor.Rendering.Fullscreen.ShaderGraph.FullscreenShaderGUI"
    FallBack"Hidden/Shader Graph/FallbackError"
}