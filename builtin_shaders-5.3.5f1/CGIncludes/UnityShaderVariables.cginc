#ifndef UNITY_SHADER_VARIABLES_INCLUDED
#define UNITY_SHADER_VARIABLES_INCLUDED

#include "HLSLSupport.cginc"

#if defined (DIRECTIONAL_COOKIE) || defined (DIRECTIONAL)
#define USING_DIRECTIONAL_LIGHT
#endif



// ----------------------------------------------------------------------------

CBUFFER_START(UnityPerCamera)
	// Time (t = time since current level load) values from Unity
	uniform float4 _Time; // (t/20, t, t*2, t*3)
	uniform float4 _SinTime; // sin(t/8), sin(t/4), sin(t/2), sin(t)
	uniform float4 _CosTime; // cos(t/8), cos(t/4), cos(t/2), cos(t)
	uniform float4 unity_DeltaTime; // dt, 1/dt, smoothdt, 1/smoothdt
	
	uniform float3 _WorldSpaceCameraPos; //摄像机位置
	
	// x = 1 or -1 (-1 if projection is flipped)
	// y = near plane
	// z = far plane
	// w = 1/far plane
	uniform float4 _ProjectionParams; //近平面和远平面的位置。
	
	// x = width
	// y = height
	// z = 1 + 1.0/width
	// w = 1 + 1.0/height
	uniform float4 _ScreenParams;//屏幕宽高参数
	
	// Values used to linearize the Z buffer (http://www.humus.name/temp/Linearize%20depth.txt)
	// x = 1-far/near
	// y = far/near
	// z = x/far
	// w = y/far
	uniform float4 _ZBufferParams; //应该是延迟渲染中用吧(根据深度值 推出该位置的世界坐标)

	// x = orthographic camera's width
	// y = orthographic camera's height
	// z = unused
	// w = 1.0 if camera is ortho, 0.0 if perspective
	uniform float4 unity_OrthoParams;
CBUFFER_END


CBUFFER_START(UnityPerCameraRare)
	uniform float4 unity_CameraWorldClipPlanes[6];

	// Projection matrices of the camera. Note that this might be different from projection matrix
	// that is set right now, e.g. while rendering shadows the matrices below are still the projection
	// of original camera.
	uniform float4x4 unity_CameraProjection;
	uniform float4x4 unity_CameraInvProjection;
CBUFFER_END



// ----------------------------------------------------------------------------

CBUFFER_START(UnityLighting) //光照的参数

	//_WorldSpaceLightPos0.w可以表明该光源的类型，如果为0表示是平行光，为1表示是点光源或者聚光灯光源。
	#ifdef USING_DIRECTIONAL_LIGHT
	uniform half4 _WorldSpaceLightPos0; //位置  lightdir = nor(lightpos)  光源的向量
	#else
	uniform float4 _WorldSpaceLightPos0;
	#endif

	uniform float4 _LightPositionRange; // xyz = pos, w = 1/range 点光源才有效 阴影的时候才会有值

//四个非重要的光源 逐顶点
	float4 unity_4LightPosX0;  // x coordinates of the 4 light sources in world space  
	float4 unity_4LightPosY0;  // y coordinates of the 4 light sources in world space
	float4 unity_4LightPosZ0;  // z coordinates of the 4 light sources in world space  
	half4 unity_4LightAtten0; //scale factors for attenuation with squared distance 
//四个非重要的光源 逐顶点
	half4 unity_LightColor[8]; //0-4 是给四个非重要的光源用的 


	float4 unity_LightPosition[8]; // view-space vertex light positions (position,1), or (-direction,0) for directional lights.
	// x = cos(spotAngle/2) or -1 for non-spot
	// y = 1/cos(spotAngle/4) or 1 for non-spot
	// z = quadratic attenuation
	// w = range*range
	half4 unity_LightAtten[8];
	float4 unity_SpotDirection[8]; // view-space spot light directions, or (0,0,1,0) for non-spot

	// SH lighting environment  球谐函数
	half4 unity_SHAr;
	half4 unity_SHAg;
	half4 unity_SHAb;
	half4 unity_SHBr;
	half4 unity_SHBg;
	half4 unity_SHBb;
	half4 unity_SHC;
CBUFFER_END

CBUFFER_START(UnityLightingOld)
	half3 unity_LightColor0, unity_LightColor1, unity_LightColor2, unity_LightColor3; // keeping those only for any existing shaders; remove in 4.0
CBUFFER_END


// ----------------------------------------------------------------------------

CBUFFER_START(UnityShadows)
	float4 unity_ShadowSplitSpheres[4];
	float4 unity_ShadowSplitSqRadii;
	float4 unity_LightShadowBias;
	float4 _LightSplitsNear;
	float4 _LightSplitsFar;
	float4x4 unity_World2Shadow[4];
	half4 _LightShadowData;
	float4 unity_ShadowFadeCenterAndType;
CBUFFER_END

#define _World2Shadow unity_World2Shadow[0]
#define _World2Shadow1 unity_World2Shadow[1]
#define _World2Shadow2 unity_World2Shadow[2]
#define _World2Shadow3 unity_World2Shadow[3]


// ----------------------------------------------------------------------------

CBUFFER_START(UnityPerDraw)
	float4x4 glstate_matrix_mvp;
	float4x4 glstate_matrix_modelview0;
	float4x4 glstate_matrix_invtrans_modelview0;
	#define UNITY_MATRIX_MVP glstate_matrix_mvp
	#define UNITY_MATRIX_MV glstate_matrix_modelview0
	#define UNITY_MATRIX_IT_MV glstate_matrix_invtrans_modelview0
	
	uniform float4x4 _Object2World;
	uniform float4x4 _World2Object;
	uniform float4 unity_LODFade; // x is the fade value ranging within [0,1]. y is x quantized into 16 levels
	uniform float4 unity_WorldTransformParams; // w is usually 1.0, or -1.0 for odd-negative scale transforms
CBUFFER_END




CBUFFER_START(UnityPerDrawRare)
	float4x4 glstate_matrix_transpose_modelview0;
	#define UNITY_MATRIX_T_MV glstate_matrix_transpose_modelview0
CBUFFER_END



// ----------------------------------------------------------------------------

CBUFFER_START(UnityPerFrame)

	float4x4 glstate_matrix_projection;
	fixed4	 glstate_lightmodel_ambient;
	#define UNITY_MATRIX_P glstate_matrix_projection

	#define UNITY_LIGHTMODEL_AMBIENT (glstate_lightmodel_ambient * 2)
	
	float4x4 unity_MatrixV;
	float4x4 unity_MatrixVP;
	#define UNITY_MATRIX_V unity_MatrixV
	#define UNITY_MATRIX_VP unity_MatrixVP
	
	fixed4 unity_AmbientSky;
	fixed4 unity_AmbientEquator;
	fixed4 unity_AmbientGround;

CBUFFER_END


// ----------------------------------------------------------------------------

CBUFFER_START(UnityFog)
	uniform fixed4 unity_FogColor;
	// x = density / sqrt(ln(2)), useful for Exp2 mode
	// y = density / ln(2), useful for Exp mode
	// z = -1/(end-start), useful for Linear mode
	// w = end/(end-start), useful for Linear mode
	uniform float4 unity_FogParams;
CBUFFER_END


// ----------------------------------------------------------------------------
// Lightmaps

// Main lightmap
UNITY_DECLARE_TEX2D(unity_Lightmap);
// Dual or directional lightmap (always used with unity_Lightmap, so can share sampler)
UNITY_DECLARE_TEX2D_NOSAMPLER(unity_LightmapInd);

// Dynamic GI lightmap
UNITY_DECLARE_TEX2D(unity_DynamicLightmap);
UNITY_DECLARE_TEX2D_NOSAMPLER(unity_DynamicDirectionality);
UNITY_DECLARE_TEX2D_NOSAMPLER(unity_DynamicNormal);

CBUFFER_START(UnityLightmaps)//光照贴图
	float4 unity_LightmapST;
	float4 unity_DynamicLightmapST;
CBUFFER_END


// ----------------------------------------------------------------------------
// Reflection Probes

UNITY_DECLARE_TEXCUBE(unity_SpecCube0);
UNITY_DECLARE_TEXCUBE(unity_SpecCube1);

CBUFFER_START(UnityReflectionProbes)
	float4 unity_SpecCube0_BoxMax;
	float4 unity_SpecCube0_BoxMin;
	float4 unity_SpecCube0_ProbePosition;
	half4  unity_SpecCube0_HDR;

	float4 unity_SpecCube1_BoxMax;
	float4 unity_SpecCube1_BoxMin;
	float4 unity_SpecCube1_ProbePosition;
	half4  unity_SpecCube1_HDR;
CBUFFER_END


// ----------------------------------------------------------------------------
//  Deprecated

// There used to be fixed function-like texture matrices, defined as UNITY_MATRIX_TEXTUREn. These are gone now; and are just defined to identity.
#define UNITY_MATRIX_TEXTURE0 float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
#define UNITY_MATRIX_TEXTURE1 float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
#define UNITY_MATRIX_TEXTURE2 float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
#define UNITY_MATRIX_TEXTURE3 float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)


#endif
