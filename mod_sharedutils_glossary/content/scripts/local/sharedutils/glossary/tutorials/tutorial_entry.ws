class SU_GlossaryTutorialEntry {
  var entry_unique_id: name;

  var drop_down_label: string;
  var drop_down_tag: name;
  var drop_down_icon: string;
  default drop_down_icon = "icons/monsters/ICO_MonsterDefault.png";

  var title: string;
  var description: string;

  var is_new: bool;
  default is_new = true;

  // This is the visible image beside the selected tutorial title.
  // Use a path relative to gameplay/gui_new, without the img:// prefix.
  var image_path: string;
  default image_path = "empty_texture.PNG";

  // Leave either dimension at zero to retain the original image sizing.
  var image_width: float;
  var image_height: float;

  function getTitle(): string {
    return this.title;
  }

  function getDescription(): string {
    return this.description;
  }

  function getImagePath(): string {
    return this.image_path;
  }

  function getIsNew(): bool {
    return this.is_new;
  }
}
