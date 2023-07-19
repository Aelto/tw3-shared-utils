statemachine class SU_TinyBootstrapperManager extends SU_StorageItem
{
	default tag = "SU_TinyBootstrapperManager";

	// Used internally by the manager to store the list of states 
	// that will bootstrap the mods.
	protected var states_to_process: array<name>;

	// The persistent list with the user-made mods
	//
	// DEPRECRATED: not used anymore but kept for backward compatibility
	protected saved var mods: array<SU_BaseBootstrappedMod>;

	protected var mods_to_bootstrap: array<SU_BaseBootstrappedMod>;
	
	public function init(): SU_TinyBootstrapperManager 
	{
		this.states_to_process = theGame.GetDefinitionsManager()
			.GetItemsWithTag('SU_TinyBootstrapperManager');

		this.mods_to_bootstrap.Clear();
		this.migrateModsToNonPeristentArray();
		this.GotoState('Initialising');
		return this;
	}

	private function migrateModsToNonPeristentArray() {
		var mod: SU_BaseBootstrappedMod;
		var i: int;

		for (i = 0; i < this.mods.Size(); i += 1) {
			mod = this.mods[i];

			if (mod) {
				// migrate the mod to the non-persistent array
				this.mods_to_bootstrap.PushBack(mod);
			}
		}

		// DEPRECATION:
		// `this.mods` is no longer used and all mods currently stored in it should
		// be migrated to SUST directly.
		this.mods.Clear();
	}
	
	protected function startMods()
	{
		var mod: SU_BaseBootstrappedMod;
		var i: int;

		for (i = 0; i < this.mods_to_bootstrap.Size(); i += 1) {
			mod = this.mods_to_bootstrap[i];

			if (mod) {
				mod.start();
			}
		}
	}
	
	public function stopMods() 
	{
		var mod: SU_BaseBootstrappedMod;
		var i: int;

		for (i = 0; i < this.mods_to_bootstrap.Size(); i += 1) 
		{
			mod = this.mods_to_bootstrap[i];

			if (mod) {
				mod.stop();
			}
		}

		this.mods_to_bootstrap.Clear();
	}
	
	public function hasModWithTag(tag: name): bool
	{
		var mod: SU_BaseBootstrappedMod;
		var i: int;

		for (i = 0; i < this.mods_to_bootstrap.Size(); i += 1) 
		{
			mod = this.mods_to_bootstrap[i];

			if (mod) {
				if (mod.tag == tag) {
					return true;
				}
			}
		}


		return false;
	}
	
	public function getModByTag(tag: name): SU_BaseBootstrappedMod
	{
		var i: int;

		for (i = 0; i < this.mods_to_bootstrap.Size(); i += 1)
		{
			if (this.mods_to_bootstrap[i].tag == tag)
			{
				return this.mods_to_bootstrap[i];
			}
		}
		return NULL;
	}
	
	public function addMod(mod: SU_BaseBootstrappedMod)
	{
		if (mod.tag == '') {
			return;
		}

		this.mods_to_bootstrap.PushBack(mod);
	}
	
	public function removeMod(mod: SU_BaseBootstrappedMod)
	{
		this.mods_to_bootstrap.Remove(mod);
	}
}