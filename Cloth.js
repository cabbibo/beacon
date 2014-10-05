function Cloth( title , mesh , extraParams ){

  var title = title || 'HELLO';
  var mesh = mesh || new THREE.Mesh( new THREE.PlaneGeometry( 10 , 10 , 200 , 200) );

  var geometry = new THREE.Geometry();

  geometry.merge( mesh.geometry , mesh.matrix );
  
 // var geometry =  || new THREE.BoxGeometry( 1000 , 1000 , 1000 , 80 , 80 , 80 );
 

  var v = geometry.vertices.length;

  var vSize = Math.ceil( Math.sqrt( v ) );
  var hSize = .5 / vSize;
  var iSize = 1. / vSize;



  //console.log( shaders.simulationShaders.n2 );
 
  var s = shaders.setValue( shaders.simulationShaders.cloth , 'SIZE'  , vSize+"." );
      s = shaders.setValue( s , 'HSIZE' , hSize+"" );
      s = shaders.setValue( s , 'ISIZE' , iSize+"" );
 
  var vs = shaders.setValue( shaders.vertexShaders.cloth , 'SIZE'  , vSize+"." );
      vs = shaders.setValue( vs , 'HSIZE' , hSize+"" );
      vs = shaders.setValue( vs , 'ISIZE' , iSize+"" );
  var dir =new THREE.Vector3( 0 , 0 , 0 )

  //dir.normalize();
        
  var params =  {

    vs: vs,
    fs: shaders.fragmentShaders.cloth,
    ss: s,

    geometry: geometry,


    dT: G_UNIFORMS.dT,
    time: G_UNIFORMS.time,

    soul:{
      
      windSpeed:     { type:"f" , value: .05  , constraints:[ 0 , 1] },
      windDirection:      { type:"v3" ,value: dir  },
      dampening:          { type:"f" , value: .95  , constraints:[ .8 , .9999 ] },
      springLength:       { type:"f" , value: .09  , constraints:[ .001 ,1 ] },
      springMultiplier:   { type:"f" , value: 500. , constraints:[ .001 ,100 ] },
      maxVel:             { type:"f" , value: .001   , constraints:[ .00001 , 1. ] },
      sample:             G_UNIFORMS.sample,
      time:               G_UNIFORMS.time,


    },

    body:{
          
      t_audio:            G_UNIFORMS.t_audio,
      lightPos:{type:"v3" , value: new THREE.Vector3( 10 , 1 , 1 )},
      audioDisplacement: { type:"f" , value: 0   , constraints:[ 0 , .3 ] },
      
    },

  }



  //Passing through extra params
 
  var extraParams = extraParams || {};
 
  if( extraParams.soul ){
    var s = extraParams.soul;
    for( var propt in s ){
      params.soul[propt] = s[propt];
    }
  }

  if( extraParams.body ){
    var s = extraParams.body;
    for( var propt in s ){
      params.body[propt] = s[propt];
    }
  }


  if( extraParams.vs ) params.vs = extraParams.vs;
  if( extraParams.fs ) params.fs = extraParams.fs;

  var gem = new GEM( params );
 
  var gHolder = document.createElement('div');

  var tHolder = document.createElement('h1');

  tHolder.innerHTML =''+ title;

  gHolder.appendChild( tHolder );
  var guis = document.getElementById( 'GUI' );

  guis.appendChild( gHolder );

  $(tHolder).click(function(){
    this.toggle();
    if( this.active ){
      this.tHolder.className = "active";
    }else{
      this.tHolder.className = "";
    }
  }.bind( gem ));


  $(tHolder).hover(function(){
    this.gui.gui.open();
  }.bind( gem ));

  $(gHolder).hover(function(){},function(){
    this.gui.gui.close();
  }.bind(gem));

  gem.tHolder = tHolder;

  gem.gui = new GUI( params , {
   domElement: gHolder 
  });


  gem.soul.reset( gem.t_og.value );
  
  return gem;

}

