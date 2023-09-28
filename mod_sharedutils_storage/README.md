# Reasons to use a sharedutils storage system
The `SU_Storage` module allows anyone to store data in the player's save in an efficient and merge friendly way.
The advantage of using a sharedutils module for storage is that even if 10 mods were to use the storage it would
still result in a single line to merge compared to 10 unique merges. All of the other sharedutils module were updated
to use the storage, greatly reducing the amount of merges created by the modules (even if they were already pretty small).

# Using it
Start by creating the type that will hold your data:
```js
class MyData extends SU_StorageItem {
  default tag = "MyData";

  var anything: string;
}
```
make yourself a function to retrieve and create the data if it's the first retrieval:
```js
function getMyData(): MyData {
  var data: MyData;

  data = (MyData)SU_getStorage().getItem("MyData");
  // create the data if it's the first time:
  if (!data) {
    data = new MyData in thePlayer;
    SU_getStorage().setItem(data);
  }

  return data;
}
```
finally use it like any other class:
```js
function example() {
  var my_data: MyData = getMyData();

  my_data.anything = "This string will be stored for later";
}
```

## Warning on persistence & removing class properties/fields
The engine deserialization process doesn't appreciate if the data that was put in the savefile has a field on a class,
and if that field is no longer present in the current code. So for example if a mod was to have a class A with a field `A.field`
in version 1.0, but the version 1.1 removes the field. Any savefile created using the version 1.0 of the mod will crash
while loading the same savefile but with the mod version 1.1.

This means that there is no way to remove a field from a type if that type is persisted to disk. However renaming or adding
fields is fine. It is then important you add fields to your types in a future-proof manner as the only way to remove a field
from a type that can be persisted is to clear the storage of any occurence of that type before saving and updating the mod.
