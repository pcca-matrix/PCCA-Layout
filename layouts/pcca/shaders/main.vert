#version 130
//uniform float width;
void main()
{
    // transform the vertex position
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    // transform the texture coordinates
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    /*gl_TexCoord[1] = gl_Vertex; // divide by screen size to have uv position
	gl_TexCoord[2] = gl_MultiTexCoord0 / width; // divide by subImgSize to have image uv
	gl_TexCoord[3] = gl_Position; // divide by subImgSize to have image uv
    */
    // forward the vertex color
    gl_FrontColor = gl_Color;
}