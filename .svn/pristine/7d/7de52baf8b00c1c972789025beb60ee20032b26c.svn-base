//--------------------------------------------------------------------
//		
//	ピクセルシェーダ構文
//
//--------------------------------------------------------------------




//-----------------------変数関連-------------------------------------



//--------------------------------------------------------------------
//	グローバル変数
//		（プログラム本体側もこの名前を使用するので名称変更には注意）
//--------------------------------------------------------------------
float4x4	camera_mat;				// 射影変換行列
float4x4	light_mat;				// カメラビュー変換行列
float4x4	world_mat : world;				// ワールド変換行列
float4x4	work_mat;				// ワーク

float4x4	camera_projection;		// 射影変換行列
float4x4	camera_view;			// カメラビュー変換行列
float4x4	light_projection;		// 射影変換行列
float4x4	light_view;				// カメラビュー変換行列

texture		shader_texture;			//テクスチャ
texture		shadowmap_texture;		// シャドウマップテクスチャ



//--------------------------------------------------------------------
//	テクスチャのサンプリング方法
//--------------------------------------------------------------------

sampler DefSampler = sampler_state		// サンプラーステート
{
    texture		= <shader_texture>;
    AddressU 	= CLAMP;        
    AddressV 	= CLAMP;
    AddressW	= CLAMP;
    MIPFILTER	= LINEAR;
    MINFILTER	= LINEAR;
    MAGFILTER	= LINEAR;
};

sampler MeshTextureSampler = sampler_state
{
	Texture = <shader_texture>;		//対象のテクスチャ(外部から受け取ります)
	MinFilter = LINEAR; 			//縮小時のサンプリング(LINEAR→線形補完)
	MagFilter = LINEAR;				//拡大時
	MipFilter = NONE;				//ミップマップ

	//テクスチャアドレッシングモード
	AddressU = Mirror;				//（Clanp→0～1以外の座標の時に端っこのピクセルをひきのばす）
	AddressV = Mirror;				// mirror
};







//--------------------------------------------------------------------
//	外部からの受取
//--------------------------------------------------------------------
float		shader_time;				//現在の進行時間や進行度
float		shader_fwork1;				//外部からもらえるパラメタ
float		shader_fwork2;
float		shader_fwork3;				//外部からもらえるパラメタ
float		shader_fwork4;
float		color_r;					//スプライトパレット
float		color_g;
float		color_b;
float		color_a;
















//---------------------出力定義---------------------------------------


//--------------------------------------------------------------------
//頂点シェーダの出力定義
//--------------------------------------------------------------------
struct VS_OUTPUT
{
	float4 pos 		: POSITION;
	float4 diffuse 	: COLOR0;
	float2 tex_uv	: TEXCOORD0;
};
struct VS_INPUT 
{
	float4 pos		: POSITION;
	float4 normal 	: NORMAL;
	float4 diffuse	: COLOR0;
	float2 tex_uv 	: TEXCOORD0;
};



//--------------------------------------------------------------------
//ピクセルシェーダ出力定義
//--------------------------------------------------------------------
struct PS_OUTPUT
{
    float4 rgb		: COLOR0;
};

struct PS_INPUT
{
	float4 pos		: POSITION;
	float4 normal 	: NORMAL;
	float4 diffuse	: COLOR0;
	float2 tex_uv 	: TEXCOORD0;
};




//--------------------------------------------------------------------
//頂点シェーダの出力定義（テクスチャなし）
//--------------------------------------------------------------------
struct VS_OUTPUT_NOTEX
{
	float4 pos				: POSITION;
	float4 diffuse			: COLOR0;
};


struct VS_OUTPUT_ZBUF
{
   float4 pos				: POSITION;   // 射影変換座標
   float4 shadow_tex		: TEXCOORD0;   // Zバッファテクスチャ
};




























//------------------------シェーダ本体--------------------------------





//--------------------------------------------------------------------
//頂点シェーダ処理（主に座標変換）
//--------------------------------------------------------------------
VS_OUTPUT RenderSceneVS( VS_INPUT in_data )
{
	VS_OUTPUT out_data;

	out_data.pos		= mul( in_data.pos, camera_mat);
	out_data.tex_uv		= in_data.tex_uv;
	out_data.diffuse	= in_data.diffuse;

	return out_data;

}


//--------------------------------------------------------------------
//ピクセルシェーダ処理（テクスチャ色に頂点色を合成）
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS( PS_INPUT in_data )
{
	PS_OUTPUT out_data;

	out_data.rgb = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	return out_data;
}






//--------------------------------------------------------------------
//モノクローム変換
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Mono( PS_INPUT in_data )
{
	PS_OUTPUT	out_data;
	float4		color;
	float		light;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;
	light = 0.299 * color.r + color.g * 0.587 + color.b * 0.114;

	out_data.rgb.r = light;
	out_data.rgb.g = light;
	out_data.rgb.b = light;
	out_data.rgb.w = 1.0;

	return out_data;
}

//--------------------------------------------------------------------
//ホワイトフラッシュ
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Whiteflash( PS_INPUT in_data )
{
	PS_OUTPUT	out_data;
	float4		color;
	float		light;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	out_data.rgb.w = color.w;

	if( out_data.rgb.w >= 0.05f )
	{
		out_data.rgb.r = 0xff;
		out_data.rgb.g = 0xff;
		out_data.rgb.b = 0xff;
	}
	else
	{
		out_data.rgb.r = color.r;
		out_data.rgb.g = color.g;
		out_data.rgb.b = color.b;		
	}

	return out_data;
}



//--------------------------------------------------------------------
//ブライト処理
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_bright( PS_INPUT in_data )
{
	PS_OUTPUT	out_data;
	float4		color;
	float		light, ans;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	//最初にすべてのピクセル要素の通常の値を入れておく。
	out_data.rgb.r = color.r;
	out_data.rgb.g = color.g;
	out_data.rgb.b = color.b;
	out_data.rgb.w = color.w;

	ans = color_r;
	if( ans >= 1.0f )			//一応systemOZでもチェックはしているけど
	{
		light = (ans - 1.0f); 	//計算結果は 0.0 ～ 1.0fに収まるはず

		out_data.rgb.r =  color.r + ( 1.0f - color.r )  * light;
		out_data.rgb.g =  color.g + ( 1.0f - color.g )  * light;
		out_data.rgb.b =  color.b + ( 1.0f - color.b )  * light;

//		ans = ans - 1.0f;
//		out_data.rgb.r =  ans;
//		out_data.rgb.g =  ans;
//		out_data.rgb.b =  ans;
	}	

	return out_data;




//	PS_OUTPUT out_data;
//	float4 color;
//	float2 pos;

//	pos.x = in_data.tex_uv.x + sin( shader_time + in_data.tex_uv.y * shader_fwork3 ) * shader_fwork1;
//	pos.y = in_data.tex_uv.y + sin( shader_time + in_data.tex_uv.x * shader_fwork4 ) * shader_fwork2;
//	color = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色

//	out_data.rgb.r = color.r;
//	out_data.rgb.g = color.g;
//	out_data.rgb.b = color.b;
//	out_data.rgb.w = 1.0;
}



//--------------------------------------------------------------------
//レッドフラッシュ
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Redflash( PS_INPUT in_data )
{
	PS_OUTPUT	out_data;
	float4		color;
	float		light;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	out_data.rgb.w = color.w;

	if( out_data.rgb.w >= 0.05f )
	{
		out_data.rgb.r = 1.0f;
		out_data.rgb.g = 0x00;
		out_data.rgb.b = 0x00;
	}
	else
	{
		out_data.rgb.r = color.r;
		out_data.rgb.g = color.g;
		out_data.rgb.b = color.b;		
	}

	return out_data;
}









//--------------------------------------------------------------------
//被写界深度用ぼかし
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Blur( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color, tomono, color2;
	float2 pos;
	float fx, fy, depth, depth_4;
	float cr = 0.0, cg = 0.0, cb = 0.0;
	int cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;	//テクスチャのピクセル色に頂点色を合成した色
	
	cnt = 0;
	depth_4 = shader_time;

	pos = in_data.tex_uv;
	pos.x -= shader_time * 2;
	pos.y -= shader_time * 2;
	pos.x += depth_4;
	pos.y += depth_4;


	//正方向
	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4;
	pos.y += depth_4;





	//逆方向
	pos = in_data.tex_uv;
	pos.x += shader_time * 2;
	pos.y -= shader_time * 2;
	pos.x -= depth_4;
	pos.y += depth_4;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4;
	pos.y += depth_4;



	cr += color.r;			//最後に中心を強くする
	cg += color.g;
	cb += color.b;
	cnt++;

	

	out_data.rgb.r = cr / cnt;
	out_data.rgb.g = cg / cnt;
	out_data.rgb.b = cb / cnt;
	out_data.rgb.w = 1.0;

	return out_data;
}










//--------------------------------------------------------------------
//被写界深度用ぼかし
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_DarkBlur( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4	color, tomono, color2;
	float2	pos;
	float	fx, fy, depth, depth_4, light;
	float	cr = 0.0, cg = 0.0, cb = 0.0;
	int		cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;				//テクスチャのピクセル色に頂点色を合成した色

	light = 0.299 * color.r + color.g * 0.587 + color.b * 0.114;
	light = 1 - light;														//輝度を反転

	cnt = 0;
	depth_4 = shader_time * light;

	pos = in_data.tex_uv;
	pos.x -= shader_time * light * 2;
	pos.y -= shader_time * light * 2;
	pos.x += depth_4;
	pos.y += depth_4;


	//正方向
	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4;
	pos.y += depth_4;



	//逆方向
	pos = in_data.tex_uv;
	pos.x += shader_time * light * 2;
	pos.y -= shader_time * light * 2;
	pos.x -= depth_4;
	pos.y += depth_4;



	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4;
	pos.y += depth_4;
	

	out_data.rgb.r = cr / cnt;
	out_data.rgb.g = cg / cnt;
	out_data.rgb.b = cb / cnt;
	out_data.rgb.w = 1.0;

	return out_data;
}













//--------------------------------------------------------------------
//ラスタ処理
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Raster( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color;
	float2 pos;

	pos.x = in_data.tex_uv.x + sin( shader_time + in_data.tex_uv.y * shader_fwork3 ) * shader_fwork1;
	pos.y = in_data.tex_uv.y + sin( shader_time + in_data.tex_uv.x * shader_fwork4 ) * shader_fwork2;
	color = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//テクスチャのピクセル色に頂点色を合成した色

	out_data.rgb.r = color.r;
	out_data.rgb.g = color.g;
	out_data.rgb.b = color.b;
	out_data.rgb.w = 1.0;

	return out_data;
}








//--------------------------------------------------------------------
//被写界深度用ぼかし
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_WhiteCut( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color, tomono, color2;
	float2 pos;
	float fx, fy, depth, depth_4, light;
	float cr = 0.0, cg = 0.0, cb = 0.0;
	int cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;				//テクスチャのピクセル色に頂点色を合成した色

	light = 0.299 * color.r + color.g * 0.587 + color.b * 0.114;

	if( light >= 0.9 )
	{
		color.r = 0;
		color.g = 0;
		color.b = 0;
		color.w = 0;
	} 

	out_data.rgb.r = color.r;
	out_data.rgb.g = color.g;
	out_data.rgb.b = color.b;
	out_data.rgb.w = color.w;

	return out_data;

}






//--------------------------------------------------------------------
//可視化Zバッファへの書き出し
//--------------------------------------------------------------------
VS_OUTPUT_ZBUF LIGHTVIEW_ZBuffer_Draw_VS( float4 pos : POSITION )
{
	VS_OUTPUT_ZBUF out_data = ( VS_OUTPUT_ZBUF )0;
	float4x4 mat;

	mat = mul( world_mat, light_mat);
	out_data.pos = mul( pos, mat);
	out_data.shadow_tex = out_data.pos;  							 // テクスチャ座標を頂点に合わせる


	//遠矢追記：残念なことに、ワールドマトリクスの計算の「位置」の計算をシェーダ内とDirectX内で
	//２重に行っている状態である。なんとかならないものか？


	return out_data;
}

// ピクセルシェーダ
float4 LIGHTVIEW_ZBuffer_Draw_PS( float4 shadow_tex : TEXCOORD0 ) : COLOR
{
	float4 col;

	col.x = shadow_tex.z / shadow_tex.w;
	col.y = shadow_tex.z / shadow_tex.w;
	col.z = shadow_tex.z / shadow_tex.w;
	col.w = 1.0f;

 	return col;   // Z値算出
}






//--------------------------------------------------------------------
// 8 : 深度バッファシャドウのレンダリング
//（ライト視点からレンダリングされたZバッファが必須）
//--------------------------------------------------------------------

struct VS_OUTPUT_SB
{
   float4 pos 		: POSITION;  			// 射影変換座標
   float4 z_calc_tex: TEXCOORD0;		   	// Z値算出用テクスチャ
   float4 col		: COLOR0;				// ディフューズ色
};




// 頂点シェーダ
VS_OUTPUT_SB DepthBufShadow_VS( float4 pos : POSITION , float3 Norm : NORMAL)
{
   VS_OUTPUT_SB out_data = (VS_OUTPUT_SB)0;
   float4x4 mat;

   mat  = mul( world_mat, camera_view );   					// 普通にカメラの目線によるワールドビュー射影変換をする
   mat  = mul( mat, camera_projection );
   out_data.pos = mul( pos, mat );
   
   mat  = mul( world_mat, light_view );						// ライトの目線によるワールドビュー射影変換をする
   mat  = mul( mat, light_projection );
   out_data.z_calc_tex = mul( pos, mat );
   
   float3 N = normalize( mul(Norm, world_mat) );  			 // 法線とライトの方向から頂点の色を決定 濃くなりすぎないように調節しています
   float3 LightDirect = normalize( float3( light_view._13, light_view._23, light_view._33) );
   out_data.col = float4(0.0,0.6,1.0,1.0) * (0.3 + dot(N, -LightDirect) *( 1- 0.3f ));
   
   return out_data;
}


// ピクセルシェーダ
float4 DepthBufShadow_PS( float4 col : COLOR, float4 z_calc_tex : TEXCOORD0 ) : COLOR
{
	float	z_ans = z_calc_tex.z / z_calc_tex.w;   			// ライト目線によるZ値の再算出
	float2	TransTexCoord; 									// テクスチャ座標に変換
	float	SM_Z;

	TransTexCoord.x = (1.0f + z_calc_tex.x / z_calc_tex.w) * 0.5f;
	TransTexCoord.y = (1.0f - z_calc_tex.y / z_calc_tex.w) * 0.5f;

	SM_Z = tex2D( DefSampler, TransTexCoord ).x;		// 同じ座標のZ値を抽出

	//遠矢追記
	// z_ansはちゃんと値を持ってきていた つまり  SM_Zは取れている
	//　ただ、位置はイヤにずれてない？  頂点シェーダに値をちゃんと渡せていない？
	//  

	col.r = SM_Z;				//テクスチャのピクセル色に頂点色を合成した色
	col.g = SM_Z;				//テクスチャのピクセル色に頂点色を合成した色

	if( z_ans > SM_Z + 0.005f )
	{
		col.b = 0.0;
	}
	else
	{
		col.b = 0.0f;		
	}

	col.a = 0.564;
	//	if( z_ans > SM_Z + 0.005f )
	//	{
	//		col.rgb = col.rgb * 0.5f; 
	//	}

	return col;
}







//--------------------------------------------------------------------
//9:テストコード
//--------------------------------------------------------------------
VS_OUTPUT Test_VS( VS_INPUT in_data )
{
	VS_OUTPUT out_data;
	
	out_data.pos		= mul( in_data.pos, camera_mat);
	out_data.tex_uv		= in_data.tex_uv;
	out_data.diffuse	= in_data.diffuse;

	return out_data;
}

// ピクセルシェーダ
float4 Test_PS( float2 uv : TEXCOORD, float2 xy : VPOS) : COLOR
{
	float4 col = tex2D( MeshTextureSampler, uv );			//colを色として扱うため、このように書かないといけないらしい
	
	if( xy.y < 520.0 )
	{
		col.rgb = float3( 0.5, 0.0, 0.0);
	}
	else
	{
		col.rgb = float3( 0.2, 0.2, 0.2);
	}

 	return col;   // Z値算出
}










//--------------------------------------------------------------------
//テクニックとパス
//複数のテクニックやパスを定義すしてシェーダプログラムや引数を切り替えることができます。
//--------------------------------------------------------------------

technique RenderScene
{
	//カラー表示の場合
	pass P0
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS();
	}

	//テスト用
	pass P1
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Mono();
	}

	//被写界深度用ブラー
	pass P2
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Blur();
	}


	//暗いところほどブラーがかかる
	pass P3
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_DarkBlur();
	}

	//ラスター処理
	pass P4
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Raster();
	}

	//白い部分のカット
//	pass P5
//	{
//		VertexShader = compile vs_2_0 RenderSceneVS();
//		PixelShader = compile ps_2_0 RenderScenePS_WhiteCut();
//	}




	//ブライト処理
	pass P5
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_bright();	
	}



	//ホワイトフラッシュ（ダメージ表現）
	pass P6
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Whiteflash();
	}

	//レッドフラッシュ（ダメージ状態表現）
	pass P7
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Redflash();
	}

	//可視化可能なZバッファに情報を転送
//	pass P7
//	{
//		VertexShader = compile vs_3_0 LIGHTVIEW_ZBuffer_Draw_VS();
///		PixelShader  = compile ps_3_0 LIGHTVIEW_ZBuffer_Draw_PS();
//	}

	//シャドウレンダリング（深度バッファシャドウ）　必要なものはライト視点からレンダリングされたZバッファ
	pass P8
	{
		VertexShader = compile vs_3_0 DepthBufShadow_VS();
		PixelShader  = compile ps_3_0 DepthBufShadow_PS();
	}

	//テスト
	pass P9
	{
		VertexShader = compile vs_3_0 Test_VS();
		PixelShader  = compile ps_3_0 Test_PS();
	}


}




