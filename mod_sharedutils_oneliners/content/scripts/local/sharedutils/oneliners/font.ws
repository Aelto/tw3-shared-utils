class SUOL_TagBuilder {
  private var buffer: string;

  private var self_closing: bool;
  default self_closing = true;

  private var _tag: string;
  public function tag(value: string): SUOL_TagBuilder {
    this._tag = value;
    this.buffer = "<" + value;

    return this;
  }

  public function attr(key: string, value: string): SUOL_TagBuilder {
    this.buffer += " ";
    this.buffer += key;
    this.buffer += "=\"";
    this.buffer += value;
    this.buffer +="\"";

    return this;
  }

  public function text(value: string): string {
    this.buffer += ">" + value;

    return this.buffer + "</" + this._tag + ">";
  }

  public function close(): string {
    return this.buffer + " />";
  }
}