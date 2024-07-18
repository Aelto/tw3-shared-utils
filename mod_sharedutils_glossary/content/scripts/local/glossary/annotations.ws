@addField(CR4Player)
var sharedutils_glossary: SU_GlossaryManager;

@addMethod(CR4Player)
function getSharedutilsGlossaryManager(): SU_GlossaryManager {
  if (!this.sharedutils_glossary) {
    this.sharedutils_glossary = new SU_GlossaryManager in this;
  }

  return this.sharedutils_glossary;
}

@wrapMethod(CR4GlossaryBooksMenu)
function PopulateListData( booksList : array< name >, out flashDataList : CScriptedFlashArray ) : void {
  wrappedMethod(booksList, flashDataList);
  SUG_populateListData(flashDataList, this.m_flashValueStorage);
}