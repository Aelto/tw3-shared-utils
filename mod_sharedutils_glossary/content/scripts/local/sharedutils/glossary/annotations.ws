@addField(CR4Player)
var sharedutils_glossary: SU_GlossaryManager;

@addMethod(CR4Player)
function getSharedutilsGlossaryManager(): SU_GlossaryManager {
  if (!this.sharedutils_glossary) {
    this.sharedutils_glossary = new SU_GlossaryManager in this;
  }

  return this.sharedutils_glossary;
}

// use a flag to inject only once per call to `PopulateData()`
@addField(CR4GlossaryBooksMenu)
var sharedutils_glossary_can_inject: bool;

@wrapMethod(CR4GlossaryBooksMenu)
function PopulateData() {
  this.sharedutils_glossary_can_inject = true;
  wrappedMethod();
}

// This function is unfortunately called twice but it is the only way to get
// access to the `out flashDataList` and inject things in it.
//
// The flag ensures we inject our data only once
@wrapMethod(CR4GlossaryBooksMenu)
function PopulateListData( booksList : array< name >, out flashDataList : CScriptedFlashArray ) : void {
  wrappedMethod(booksList, flashDataList);

  if (this.sharedutils_glossary_can_inject) {
    SUG_populateListData(flashDataList, this.m_flashValueStorage);
    this.sharedutils_glossary_can_inject = false;
  }
}