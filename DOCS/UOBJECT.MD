# TObject Class

The TObject class is the common ancestor for all classes in leanlib. 
It includes manual reference counting for memory management, object messaging, delegation, and object comparison.

### Initialization

This class is not intended to be initialized directly. You should define your own class based on this one and create instances of that class instead. 

### Memory management

leanlib uses manual memory reference counting. This means that the developer is responsible for initializing, retaining and releasing instances.

Each object is created with a reference count of one. When the reference count becomes zero, the object is destroyed and its memory is released. The reference counter increments with each call to *retain* and it decreases with each call to *release*.

As a general rule, the same block that creates an instance must also release it at the end of it. For instance:

     begin
       myObject := new(PMyObject, init)
       ...
       myObject^.release;
     end;

When an object is defined as a property of another object, we often create it in the *init* constructor and release it in the *done* destructor. For instance:

     constructor TMyObject.init;
     begin
       inherited init;
       mylist := new (PList, init)
     end;

     destructor TMyObject.done;
     begin  
       mylist^.release;
       inherited done;
     end;

The concept of *ownership* is very much important when retaining and releasing instances. For instance, a list owns the items contained in it. If this wasn't the case, when an item becomes destroyed, the list would contain an invalid reference to it. Therefore, to prevent the list from ever having an invalid item reference we make it retain the instance and release it when the list is destroyed or the element removed from it.

If three lists own the same item, this will have the effect of making sure that the item is not released until it is removed from all three lists.

Another common case of retaining is when an object is initialized and provided with instances as parameters to its constructor. For instance, an object A that requires an object B to function properly will retain B during its entire lifecycle until it releases it in its destructor.

### Object messaging

The TObject class offers a mechanism to communicate any object with any other object by passing messages. These are not the traditional kind of message in the sense of one object calling another object's methods. This messaging requires passing a reference to a record that contains information such as an operation identifier or *opcode*, a reference to the *sender* of the message, a reference to the intended *target* object, a pointer to a *payload* and the *size* of it. This information is contained in the TObjectMessage record. 

For an object to react to a message it needs to override the *receiveMessage* method. An object can also send a message to another object by using the *sendMessage* and *sendMessageWithData* convenience methods which work by creating and initializing a TObjectMessage record and passing it as an argument to the target object's *receiveMessage* method. 

Object messaging is specially useful when used in combination with object buses like lists. For instance, you could send a message to a list which in turn could send it to all its contained items. 

### Delegation

Delegation is a pattern used to report to another object changes or events happening on the current object. For instance, when a key is pressed, a Keyboard object may call its delegate and inform it which key was pressed.

Since this pattern is so common as a way to communicate between objects it is included in the base TObject class in other to make it a standard for leanlib. 

### Object comparison

Sometimes you need to be able to compare an object with another. This is often done when sorting a list of elements. In this case, during the sorting process comparisons are made which need to be resolved as Greater, Lesser or Equal. Sometimes objects simply cannot be compared, in which case the result becomes undefined. All these cases are established by the ECompareResult type. 
