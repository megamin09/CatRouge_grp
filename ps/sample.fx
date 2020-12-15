//--------------------------------------------------------------------
//		
//	�s�N�Z���V�F�[�_�\��
//
//--------------------------------------------------------------------




//-----------------------�ϐ��֘A-------------------------------------



//--------------------------------------------------------------------
//	�O���[�o���ϐ�
//		�i�v���O�����{�̑������̖��O���g�p����̂Ŗ��̕ύX�ɂ͒��Ӂj
//--------------------------------------------------------------------
float4x4	camera_mat;				// �ˉe�ϊ��s��
float4x4	light_mat;				// �J�����r���[�ϊ��s��
float4x4	world_mat : world;				// ���[���h�ϊ��s��
float4x4	work_mat;				// ���[�N

float4x4	camera_projection;		// �ˉe�ϊ��s��
float4x4	camera_view;			// �J�����r���[�ϊ��s��
float4x4	light_projection;		// �ˉe�ϊ��s��
float4x4	light_view;				// �J�����r���[�ϊ��s��

texture		shader_texture;			//�e�N�X�`��
texture		shadowmap_texture;		// �V���h�E�}�b�v�e�N�X�`��



//--------------------------------------------------------------------
//	�e�N�X�`���̃T���v�����O���@
//--------------------------------------------------------------------

sampler DefSampler = sampler_state		// �T���v���[�X�e�[�g
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
	Texture = <shader_texture>;		//�Ώۂ̃e�N�X�`��(�O������󂯎��܂�)
	MinFilter = LINEAR; 			//�k�����̃T���v�����O(LINEAR�����`�⊮)
	MagFilter = LINEAR;				//�g�厞
	MipFilter = NONE;				//�~�b�v�}�b�v

	//�e�N�X�`���A�h���b�V���O���[�h
	AddressU = Mirror;				//�iClanp��0�`1�ȊO�̍��W�̎��ɒ[�����̃s�N�Z�����Ђ��̂΂��j
	AddressV = Mirror;				// mirror
};







//--------------------------------------------------------------------
//	�O������̎��
//--------------------------------------------------------------------
float		shader_time;				//���݂̐i�s���Ԃ�i�s�x
float		shader_fwork1;				//�O��������炦��p�����^
float		shader_fwork2;
float		shader_fwork3;				//�O��������炦��p�����^
float		shader_fwork4;
float		color_r;					//�X�v���C�g�p���b�g
float		color_g;
float		color_b;
float		color_a;
















//---------------------�o�͒�`---------------------------------------


//--------------------------------------------------------------------
//���_�V�F�[�_�̏o�͒�`
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
//�s�N�Z���V�F�[�_�o�͒�`
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
//���_�V�F�[�_�̏o�͒�`�i�e�N�X�`���Ȃ��j
//--------------------------------------------------------------------
struct VS_OUTPUT_NOTEX
{
	float4 pos				: POSITION;
	float4 diffuse			: COLOR0;
};


struct VS_OUTPUT_ZBUF
{
   float4 pos				: POSITION;   // �ˉe�ϊ����W
   float4 shadow_tex		: TEXCOORD0;   // Z�o�b�t�@�e�N�X�`��
};




























//------------------------�V�F�[�_�{��--------------------------------





//--------------------------------------------------------------------
//���_�V�F�[�_�����i��ɍ��W�ϊ��j
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
//�s�N�Z���V�F�[�_�����i�e�N�X�`���F�ɒ��_�F�������j
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS( PS_INPUT in_data )
{
	PS_OUTPUT out_data;

	out_data.rgb = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	return out_data;
}






//--------------------------------------------------------------------
//���m�N���[���ϊ�
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
//�z���C�g�t���b�V��
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
//�u���C�g����
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_bright( PS_INPUT in_data )
{
	PS_OUTPUT	out_data;
	float4		color;
	float		light, ans;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;

	//�ŏ��ɂ��ׂẴs�N�Z���v�f�̒ʏ�̒l�����Ă����B
	out_data.rgb.r = color.r;
	out_data.rgb.g = color.g;
	out_data.rgb.b = color.b;
	out_data.rgb.w = color.w;

	ans = color_r;
	if( ans >= 1.0f )			//�ꉞsystemOZ�ł��`�F�b�N�͂��Ă��邯��
	{
		light = (ans - 1.0f); 	//�v�Z���ʂ� 0.0 �` 1.0f�Ɏ��܂�͂�

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
//	color = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F

//	out_data.rgb.r = color.r;
//	out_data.rgb.g = color.g;
//	out_data.rgb.b = color.b;
//	out_data.rgb.w = 1.0;
}



//--------------------------------------------------------------------
//���b�h�t���b�V��
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
//��ʊE�[�x�p�ڂ���
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Blur( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color, tomono, color2;
	float2 pos;
	float fx, fy, depth, depth_4;
	float cr = 0.0, cg = 0.0, cb = 0.0;
	int cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;	//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	
	cnt = 0;
	depth_4 = shader_time;

	pos = in_data.tex_uv;
	pos.x -= shader_time * 2;
	pos.y -= shader_time * 2;
	pos.x += depth_4;
	pos.y += depth_4;


	//������
	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4;
	pos.y += depth_4;





	//�t����
	pos = in_data.tex_uv;
	pos.x += shader_time * 2;
	pos.y -= shader_time * 2;
	pos.x -= depth_4;
	pos.y += depth_4;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4;
	pos.y += depth_4;



	cr += color.r;			//�Ō�ɒ��S����������
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
//��ʊE�[�x�p�ڂ���
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_DarkBlur( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4	color, tomono, color2;
	float2	pos;
	float	fx, fy, depth, depth_4, light;
	float	cr = 0.0, cg = 0.0, cb = 0.0;
	int		cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;				//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F

	light = 0.299 * color.r + color.g * 0.587 + color.b * 0.114;
	light = 1 - light;														//�P�x�𔽓]

	cnt = 0;
	depth_4 = shader_time * light;

	pos = in_data.tex_uv;
	pos.x -= shader_time * light * 2;
	pos.y -= shader_time * light * 2;
	pos.x += depth_4;
	pos.y += depth_4;


	//������
	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x += depth_4;
	pos.y += depth_4;



	//�t����
	pos = in_data.tex_uv;
	pos.x += shader_time * light * 2;
	pos.y -= shader_time * light * 2;
	pos.x -= depth_4;
	pos.y += depth_4;



	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	cr += color2.r;
	cg += color2.g;
	cb += color2.b;
	cnt++;
	pos.x -= depth_4 * 2;
	pos.y += depth_4 * 2;


	color2 = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
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
//���X�^����
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_Raster( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color;
	float2 pos;

	pos.x = in_data.tex_uv.x + sin( shader_time + in_data.tex_uv.y * shader_fwork3 ) * shader_fwork1;
	pos.y = in_data.tex_uv.y + sin( shader_time + in_data.tex_uv.x * shader_fwork4 ) * shader_fwork2;
	color = tex2D( MeshTextureSampler, pos ) * in_data.diffuse;		//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F

	out_data.rgb.r = color.r;
	out_data.rgb.g = color.g;
	out_data.rgb.b = color.b;
	out_data.rgb.w = 1.0;

	return out_data;
}








//--------------------------------------------------------------------
//��ʊE�[�x�p�ڂ���
//--------------------------------------------------------------------
PS_OUTPUT RenderScenePS_WhiteCut( PS_INPUT in_data )
{
	PS_OUTPUT out_data;
	float4 color, tomono, color2;
	float2 pos;
	float fx, fy, depth, depth_4, light;
	float cr = 0.0, cg = 0.0, cb = 0.0;
	int cnt;

	color = tex2D( MeshTextureSampler, in_data.tex_uv ) * in_data.diffuse;				//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F

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
//����Z�o�b�t�@�ւ̏����o��
//--------------------------------------------------------------------
VS_OUTPUT_ZBUF LIGHTVIEW_ZBuffer_Draw_VS( float4 pos : POSITION )
{
	VS_OUTPUT_ZBUF out_data = ( VS_OUTPUT_ZBUF )0;
	float4x4 mat;

	mat = mul( world_mat, light_mat);
	out_data.pos = mul( pos, mat);
	out_data.shadow_tex = out_data.pos;  							 // �e�N�X�`�����W�𒸓_�ɍ��킹��


	//����ǋL�F�c�O�Ȃ��ƂɁA���[���h�}�g���N�X�̌v�Z�́u�ʒu�v�̌v�Z���V�F�[�_����DirectX����
	//�Q�d�ɍs���Ă����Ԃł���B�Ȃ�Ƃ��Ȃ�Ȃ����̂��H


	return out_data;
}

// �s�N�Z���V�F�[�_
float4 LIGHTVIEW_ZBuffer_Draw_PS( float4 shadow_tex : TEXCOORD0 ) : COLOR
{
	float4 col;

	col.x = shadow_tex.z / shadow_tex.w;
	col.y = shadow_tex.z / shadow_tex.w;
	col.z = shadow_tex.z / shadow_tex.w;
	col.w = 1.0f;

 	return col;   // Z�l�Z�o
}






//--------------------------------------------------------------------
// 8 : �[�x�o�b�t�@�V���h�E�̃����_�����O
//�i���C�g���_���烌���_�����O���ꂽZ�o�b�t�@���K�{�j
//--------------------------------------------------------------------

struct VS_OUTPUT_SB
{
   float4 pos 		: POSITION;  			// �ˉe�ϊ����W
   float4 z_calc_tex: TEXCOORD0;		   	// Z�l�Z�o�p�e�N�X�`��
   float4 col		: COLOR0;				// �f�B�t���[�Y�F
};




// ���_�V�F�[�_
VS_OUTPUT_SB DepthBufShadow_VS( float4 pos : POSITION , float3 Norm : NORMAL)
{
   VS_OUTPUT_SB out_data = (VS_OUTPUT_SB)0;
   float4x4 mat;

   mat  = mul( world_mat, camera_view );   					// ���ʂɃJ�����̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
   mat  = mul( mat, camera_projection );
   out_data.pos = mul( pos, mat );
   
   mat  = mul( world_mat, light_view );						// ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
   mat  = mul( mat, light_projection );
   out_data.z_calc_tex = mul( pos, mat );
   
   float3 N = normalize( mul(Norm, world_mat) );  			 // �@���ƃ��C�g�̕������璸�_�̐F������ �Z���Ȃ肷���Ȃ��悤�ɒ��߂��Ă��܂�
   float3 LightDirect = normalize( float3( light_view._13, light_view._23, light_view._33) );
   out_data.col = float4(0.0,0.6,1.0,1.0) * (0.3 + dot(N, -LightDirect) *( 1- 0.3f ));
   
   return out_data;
}


// �s�N�Z���V�F�[�_
float4 DepthBufShadow_PS( float4 col : COLOR, float4 z_calc_tex : TEXCOORD0 ) : COLOR
{
	float	z_ans = z_calc_tex.z / z_calc_tex.w;   			// ���C�g�ڐ��ɂ��Z�l�̍ĎZ�o
	float2	TransTexCoord; 									// �e�N�X�`�����W�ɕϊ�
	float	SM_Z;

	TransTexCoord.x = (1.0f + z_calc_tex.x / z_calc_tex.w) * 0.5f;
	TransTexCoord.y = (1.0f - z_calc_tex.y / z_calc_tex.w) * 0.5f;

	SM_Z = tex2D( DefSampler, TransTexCoord ).x;		// �������W��Z�l�𒊏o

	//����ǋL
	// z_ans�͂����ƒl�������Ă��Ă��� �܂�  SM_Z�͎��Ă���
	//�@�����A�ʒu�̓C���ɂ���ĂȂ��H  ���_�V�F�[�_�ɒl�������Ɠn���Ă��Ȃ��H
	//  

	col.r = SM_Z;				//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F
	col.g = SM_Z;				//�e�N�X�`���̃s�N�Z���F�ɒ��_�F�����������F

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
//9:�e�X�g�R�[�h
//--------------------------------------------------------------------
VS_OUTPUT Test_VS( VS_INPUT in_data )
{
	VS_OUTPUT out_data;
	
	out_data.pos		= mul( in_data.pos, camera_mat);
	out_data.tex_uv		= in_data.tex_uv;
	out_data.diffuse	= in_data.diffuse;

	return out_data;
}

// �s�N�Z���V�F�[�_
float4 Test_PS( float2 uv : TEXCOORD, float2 xy : VPOS) : COLOR
{
	float4 col = tex2D( MeshTextureSampler, uv );			//col��F�Ƃ��Ĉ������߁A���̂悤�ɏ����Ȃ��Ƃ����Ȃ��炵��
	
	if( xy.y < 520.0 )
	{
		col.rgb = float3( 0.5, 0.0, 0.0);
	}
	else
	{
		col.rgb = float3( 0.2, 0.2, 0.2);
	}

 	return col;   // Z�l�Z�o
}










//--------------------------------------------------------------------
//�e�N�j�b�N�ƃp�X
//�����̃e�N�j�b�N��p�X���`�����ăV�F�[�_�v���O�����������؂�ւ��邱�Ƃ��ł��܂��B
//--------------------------------------------------------------------

technique RenderScene
{
	//�J���[�\���̏ꍇ
	pass P0
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS();
	}

	//�e�X�g�p
	pass P1
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Mono();
	}

	//��ʊE�[�x�p�u���[
	pass P2
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Blur();
	}


	//�Â��Ƃ���قǃu���[��������
	pass P3
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_DarkBlur();
	}

	//���X�^�[����
	pass P4
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Raster();
	}

	//���������̃J�b�g
//	pass P5
//	{
//		VertexShader = compile vs_2_0 RenderSceneVS();
//		PixelShader = compile ps_2_0 RenderScenePS_WhiteCut();
//	}




	//�u���C�g����
	pass P5
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_bright();	
	}



	//�z���C�g�t���b�V���i�_���[�W�\���j
	pass P6
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Whiteflash();
	}

	//���b�h�t���b�V���i�_���[�W��ԕ\���j
	pass P7
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader = compile ps_2_0 RenderScenePS_Redflash();
	}

	//�����\��Z�o�b�t�@�ɏ���]��
//	pass P7
//	{
//		VertexShader = compile vs_3_0 LIGHTVIEW_ZBuffer_Draw_VS();
///		PixelShader  = compile ps_3_0 LIGHTVIEW_ZBuffer_Draw_PS();
//	}

	//�V���h�E�����_�����O�i�[�x�o�b�t�@�V���h�E�j�@�K�v�Ȃ��̂̓��C�g���_���烌���_�����O���ꂽZ�o�b�t�@
	pass P8
	{
		VertexShader = compile vs_3_0 DepthBufShadow_VS();
		PixelShader  = compile ps_3_0 DepthBufShadow_PS();
	}

	//�e�X�g
	pass P9
	{
		VertexShader = compile vs_3_0 Test_VS();
		PixelShader  = compile ps_3_0 Test_PS();
	}


}




