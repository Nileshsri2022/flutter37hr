class Cat{
  final String name;
  Cat(this.name);
}
extension Run on Cat{
  void run(){
    print('cat $name is running');
  }
}
class Person{
  final String firstName;
  final String lastName;

  Person(this.firstName, this.lastName);
  
}
extension FullName on Person{
  String get fullName=>'$firstName $lastName';
}
// int multipliedByTwo(int a)=>a*2;
Future<int> futureMultipliedByTwo(int a){
  // Future class is used in case of async operation
  return Future.delayed(const Duration(seconds: 3),()=>a*2);

}
void test()async{
  // this func execute command internally that do not return immediately
  // if not use await futureMultipliedByTwo return Instance of 'Future<int>'
  final result=await futureMultipliedByTwo(10);
  print(result);
}
Stream<String> getName(){
  return Stream.periodic(const Duration(seconds: 1),(value){
    return 'Foo';
  });
}
void test1()async{
  await for (final value in getName()){
    print(value);
  }
  print("Stream finished working");
}

// Generators
// Difference between List and Iterable is that 
// List is already packaged food in resturant(Fixed) and Iterable is generated on the basis of customer need 
// sync*==async but it return Stream of data
Iterable<int> getOneTwoThree()sync*{
  yield 1;
  yield 2;
  yield 3;
}
void test2()async{
  print(getOneTwoThree());
for (final value in getOneTwoThree()){
  print(value);
  if(value==2)break;
}
}
void main(){
  // extensions to add logic to existing class
  // final meow=Cat('Fluffers');
  // final foo=Person('Foo', 'Bar');
  // print(foo.fullName);
  // meow.run();
  // Future<int>
  // test();
  // stream
  // test1();
  // Generators
  test2();

  
}