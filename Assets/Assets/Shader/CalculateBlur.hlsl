//void CalculateBlur_float(
//        float directions,
//        float quality,
//        float size,
//        float2 uv,
//        UnityTexture2D mainTex,
//        out float3 color)
//{
//    float p = 6.28318530718;
//    float2 radius = size / _ScreenParams.xy;
//    float4 Color = texture(mainTex, screenpos);
//    for (float d = 0.0; d < p; d += p / directions)
//    {
//        for (float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality)
//        {
//            Color += texture(mainTex, screenpos + float2(cos(d), sin(d)) * radius * i);
//        }
//    }
//    Color /= quality * directions - 15.0;
//    color = Color;
//}

void GaussianBlur_float(UnityTexture2D inColor, float2 UV, float Blur, UnitySamplerState Sampler, out float3 Out_RGB, out float Out_Alpha)
{
    float4 col = float4(0.0, 0.0, 0.0, 0.0);
    float kernelSum = 0.0;
 
    int upper = ((Blur - 1) / 2);
    int lower = -upper;
 
    for (int x = lower; x <= upper; ++x)
    {
        for (int y = lower; y <= upper; ++y)
        {
            kernelSum++;
 
            float2 offset = float2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
            col += inColor.Sample(Sampler, UV + offset);
        }
    }
 
    col /= kernelSum;
    Out_RGB = float3(col.r, col.g, col.b);
    Out_Alpha = col.a;
}