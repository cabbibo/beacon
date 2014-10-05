vec3 springForce( vec3 p1 , vec3 p2 , float l ){

  vec3 dif = p1 - p2;
  float dL = l - length( dif );

  return (normalize( dif ) * dL);

}


vec3 springForce( vec3 p1 , vec3 p2 , float l , float p ){

  vec3 dif = p1 - p2;
  float dL = l - length( dif );

  float s = dL / abs( dL );

  return  normalize( dif ) * pow( abs( dL ) , p ) * s;

}
