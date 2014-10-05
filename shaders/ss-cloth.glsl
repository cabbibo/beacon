uniform sampler2D t_oPos;
uniform sampler2D t_pos;
uniform sampler2D t_og;
uniform sampler2D t_audio;


uniform float dT;
uniform float time;

uniform float maxVel;
uniform float springLength;
uniform float dampening;
uniform float springMultiplier;
uniform float noiseSize;
uniform float sample;

uniform vec3 windDirection;
uniform float windSpeed;
uniform float windDepth;


const float size  = @SIZE;
const float iSize = @ISIZE;
const float hSize = @HSIZE;

varying vec2 vUv;

$simplex
$springForce

void main(){

  vec4 oPos = texture2D( t_oPos , vUv );
  vec4 pos  = texture2D( t_pos , vUv );

  vec4 og   = texture2D( t_og , vUv );
  vec3 vel  = pos.xyz - oPos.xyz;
  vec3 p    = pos.xyz;

  float life = pos.w;
  
  vec3 f = vec3( 0. , 0. , 0. );
 
  vec3 dif = pos.xyz - og.xyz;

  float sl = springLength;

  float power = 2.;
 // vec3 newP = p;
  if( vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    f += springMultiplier *  normalize( nP )  * pow( length( nP ) ,  power );
  

 
  }
  
  if( vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    f += springMultiplier *  normalize( nP )  * pow( length( nP ) , power );
  

  
  }

  if( vUv.y > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    f += springMultiplier *  normalize( nP )  * pow( length( nP ) ,  power );
  
  
  }

  if( vUv.y < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x , vUv.y + iSize)).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    f += springMultiplier *  normalize( nP )  * pow( length( nP ) ,  power );
 
  }

  if( vUv.y < 1. - iSize && vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y + iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    f += springMultiplier *  normalize( nP ) * pow( length( nP ) ,  power);
  }

  if( vUv.y > iSize && vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    f += springMultiplier *  normalize( nP ) * pow( length( nP ) ,  power );

  }

  if( vUv.y > iSize && vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    f += springMultiplier *  normalize( nP )  * pow( length( nP ) ,  power ); 
  }
  
  if( vUv.y < 1. - iSize && vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y + iSize)).xyz;

    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );

  }

  //newP /= 8.;



  f /= 20.;
  

 // f -= pos.xyz * pos.xyz *pos.xyz * .1;

 // vel +=  f*min( .1 , dT);
 //  vel *= dampening;

  vec3 offset = vec3( sin( time * .0056012 ) , cos( time * .026933) , sin( time * .15248));

  float windMultiplier = snoise( pos.xyz * noiseSize + offset );

//  float windMultiplier = (abs(sin( time )) + abs(cos( time * .026933)))*.5 + 1. ;

  f += (windDirection +vec3( 0. , 0. , windDepth * windMultiplier)) * windSpeed;
  //vel *= (length( a )*length( a )*length( a ) )+.5;
 /* vel = (newP + (windDirection * windSpeed * (snoise( p * .01 +offset)*.8+1.))) *min( .1 , dT) ;
  if( length(vel) > maxVel){

    vel = normalize( vel ) * maxVel;

  }*/

 // p += 6000. * normalize( newP) * ( length( newP ) * length( newP ) * length( newP ));

 //+= windDirection * windSpeed * .0001 * windMultiplier / sample;
 
 // p += vel;//* min( .1 , dT );/// sample;


  vel = min( length(maxVel) , length(vel) )*normalize(vel) / 1.1;
  // Verlet integration 
  p = pos.xyz + (pos.xyz - oPos.xyz) * (.99 + .01*dampening) + min( .01 , dT * dT ) * f / sample;

  vec3 difP = p - pos.xyz;

  if( length( difP ) > maxVel ){

    p = pos.xyz + normalize( difP ) * maxVel * .5;
  }

  if( vUv.x < iSize ){//|| vUv.y < iSize || vUv.x > 1.- iSize ||vUv.y > 1. -iSize   ){
    p = og.xyz;
  }


  //gl_FragColor = vec4( og.xyz + sin( timer ) * 1.* vec3( vUv.x , vUv.y , 0. ), 1.  );
  gl_FragColor = vec4( p , life );

}
