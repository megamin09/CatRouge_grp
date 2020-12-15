texture PictureTexture;
sampler PictureSampler = sampler_state
{
    Texture = <PictureTexture>;
};

void FragmentProgram(
  in float4 color : COLOR0,
  in float2 texCoord : TEXCOORD0,
  out float4 colorO : COLOR0)
{
  float4 tex = tex2D(PictureSampler, texCoord);
  colorO = color * (1 - tex);
  colorO.a = color.a * tex.a;
}

technique technique_hamana
{
   pass P0
   {        
      PixelShader  = compile ps_1_1 FragmentProgram();
   }
}
