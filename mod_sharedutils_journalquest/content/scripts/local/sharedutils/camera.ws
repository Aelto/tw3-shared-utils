
class SU_StaticCamera extends CStaticCamera {
  public function start() {
    this.Run();
  }
}

latent function SU_getStaticCamera(): SU_StaticCamera {
  var template: CEntityTemplate;
  var camera: SU_StaticCamera;

  template = (CEntityTemplate)LoadResourceAsync(
    "dlc\dlcsharedutils\data\su_static_camera.w2ent",
    true
  );
  
  camera = (SU_StaticCamera)theGame.CreateEntity(
    template,
    thePlayer.GetWorldPosition(),
    thePlayer.GetWorldRotation()
  );

  return camera;
}