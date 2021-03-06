#ifndef CROSSSECTION
#define CROSSSECTION
#include"PixelShaders.fx"

bool4 EnableCrossPlane;

// Format:
// M00M01M02 PlaneNormal1 M03 Plane1 Distance to origin
// M10M11M12 PlaneNormal2 M13 Plane2 Distance to origin
// M20M21M22 PlaneNormal3 M23 Plane3 Distance to origin
// M30M31M32 PlaneNormal4 M33 Plane4 Distance to origin
float4x4 CrossPlaneParams;

float4 CrossSectionColor;

bool HasSectionFillTexture = false;
Texture2D SectionFillTexture;

void DetermineCutPlane(float3 pixelPos)
{
    if (EnableCrossPlane.x)
    {
        float3 p = pixelPos - CrossPlaneParams._m00_m01_m02 * CrossPlaneParams._m03;
        if (dot(CrossPlaneParams._m00_m01_m02, p) < 0)
        {
            discard;
        }
    }
    if (EnableCrossPlane.y)
    {
        float3 p = pixelPos - CrossPlaneParams._m10_m11_m12 * CrossPlaneParams._m13;
        if (dot(CrossPlaneParams._m10_m11_m12, p) < 0)
        {
            discard;
        }
    }
    if (EnableCrossPlane.z)
    {
        float3 p = pixelPos - CrossPlaneParams._m20_m21_m22 * CrossPlaneParams._m23;
        if (dot(CrossPlaneParams._m20_m21_m22, p) < 0)
        {
            discard;
        }
    }
    if (EnableCrossPlane.w)
    {
        float3 p = pixelPos - CrossPlaneParams._m30_m31_m32 * CrossPlaneParams._m33;
        if (dot(CrossPlaneParams._m20_m21_m22, p) < 0)
        {
            discard;
        }
    }
}

float4 PSCrossSectionShaderBlinnPhong(PSInput input) : SV_Target
{   
    DetermineCutPlane(input.wp.xyz);
    return PSShaderBlinnPhong(input);
}

float4 PSCrossSectionBackFaceShader(PSInput input) : SV_Target
{
    DetermineCutPlane(input.wp.xyz);
    return float4(0,0,0,0);
} 

static const float2 quadtexcoords[4] =
{
    float2(1, 0),
    float2(0, 0),
    float2(1, 1),
    float2(0, 1),
};

float4 CrossSectionVSMAIN(uint vI : SV_VERTEXID) : SV_Position
{
    float2 texcoord = quadtexcoords[vI];
    return float4((texcoord.x - 0.5f) * 2, -(texcoord.y - 0.5f) * 2, 0, 1);
}

float4 CrossSectionPSMAIN(float4 input : SV_POSITION) : SV_Target
{
    float4 color = CrossSectionColor;
    if (HasSectionFillTexture)
    {
        color = color * SectionFillTexture.Sample(LinearSampler, input.xy);

    }
    return color;
}
#endif