//グローバル変数
 float4x4 g_mWorldViewProjection; //座標変換行列
 texture  g_Texture;              //テクスチャ

 //テクスチャのサンプリング方法
 sampler MeshTextureSampler =
 sampler_state
 {
     Texture = < g_Texture >//対象のテクスチャ(外部から受け取ります)
     MinFilter = LINEAR; //縮小時のサンプリング(LINEAR→線形補完)
     MagFilter = LINEAR; //拡大時
     MipFilter = NONE;   //ミップマップ

     //テクスチャアドレッシングモード
     AddressU = Clamp;	//（Clanp→0～1以外の座標の時に端っこのピクセルをひきのばす）
     AddressV = Clamp;
 };










 //頂点シェーダの出力出力定義
 struct VS_OUTPUT
 {
    float4 Pos : POSITION;
    float4 Diffuse : COLOR0;
    float2 TexUV : TEXCOORD0;
 };

 //頂点シェーダ処理（主に座標変換）
 VS_OUTPUT RenderSceneVS( float4 Pos : POSITION,  float4 aDiffuse : COLOR0,  float2 vTexCoord0 : TEXCOORD0 )
 {
     VS_OUTPUT Out;

     Out.Pos = mul(Pos, g_mWorldViewProjection);
     Out.TexUV = vTexCoord0;
     Out.Diffuse = aDiffuse;

     return Out;
 }









 //ピクセルシェーダ出力定義
 struct PS_OUTPUT
 {
     float4 RGB : COLOR0;
 };

 //ピクセルシェーダ処理（テクスチャ色に頂点色を合成）
 PS_OUTPUT RenderScenePS( VS_OUTPUT In )
 {
     PS_OUTPUT Out;

     Out.RGB = tex2D( MeshTextureSampler, In.TexUV ) * In.Diffuse;
 	return Out;
 }

 //ピクセルシェーダ処理(テクスチャ色に頂点色を合成してモノクロ化)
 PS_OUTPUT RenderScenePSMono( VS_OUTPUT In )
 {
     PS_OUTPUT Out;

     //テクスチャのピクセル色に頂点色を合成した色
     float4 color = tex2D( MeshTextureSampler, In.TexUV ) * In.Diffuse;

     //モノクロ化にするときのRGBの分担割合。
     float4 tomono = float4( 0.298912, 0.586611, 0.114478, 0.0 );

     //テクスチャのピクセル色に頂点色を合成する
     Out.RGB = dot( color, tomono );

     //アルファ値だけは元のテクスチャに戻す
     Out.RGB.w = color.w;

     return Out;
 }














 //テクニックとパス
 //複数のテクニックやパスを定義すしてシェーダプログラムや引数を切り替えることができます。
 technique RenderScene
 {
     //カラー表示の場合
     pass P0
     {
         VertexShader = compile vs_2_0 RenderSceneVS();
         PixelShader = compile ps_2_0 RenderScenePS();
     }
     //モノクロ表示の場合
     pass P1
     {
         VertexShader = compile vs_2_0 RenderSceneVS();
         PixelShader = compile ps_2_0 RenderScenePSMono();
     }
 }
