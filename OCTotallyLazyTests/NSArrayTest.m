#define TL_COERCIONS
#import "OCTotallyLazyTestCase.h"

@interface NSArrayTest : OCTotallyLazyTestCase
@end

@implementation NSArrayTest

-(void)testDrop {
    NSArray *items = array(@(1), @(5), @(7), nil);
    assertThat([items drop:2], hasItems(@(7), nil));
    assertThat([items drop:1], hasItems(@(5), @(7), nil));
    assertThat([array(nil) drop:1], isEmpty());
}

-(void)testDropWhile {
    NSArray *items = array(@(7), @(5), @(4), nil);
    assertThat([items dropWhile:TL_greaterThan(@(4))], hasItems(@(4), nil));
    assertThat([items dropWhile:TL_greaterThan(@(5))], hasItems(@(5), @(4), nil));
}

- (void)testFilter {
    NSArray *items = array(@"a", @"ab", @"b", @"bc", nil);
    assertThat([items filter:^(NSString *item) { return [item hasPrefix:@"a"]; }], hasItems(@"a", @"ab", nil));
}

- (void)testFind {
    NSArray *items = array(@"a", @"ab", @"b", @"bc", nil);
    assertThat([items find:TL_startsWith(@"b")], equalTo(option(@"b")));
    assertThat([items find:TL_startsWith(@"d")], equalTo([None none]));
}

- (void)testFlatMap {
    NSArray *items = array(
            array(@"one", @"two", nil),
            array(@"three", @"four", nil),
            nil);
    assertThat([items flatMap:[Callables identity]], hasItems(@"one", @"two", @"three", @"four", nil));
}

-(void)testFlatMapFlattensOnlyOneLevel {
    NSArray *items = array(
            @"one",
            array(@"two", @"three", nil),
            array(array(@"four", nil), nil),
            nil);
    NSArray *flatMapped = [items flatMap:[Callables identity]];
    assertThat(flatMapped, hasItems(@"one", @"two", @"three", nil));
    assertThat([flatMapped objectAtIndex:3], hasItems(@"four", nil));
}

-(void)testFlattenResolvesOptions {
    NSArray *items = array(
            option(@"one"),
            array(option(nil), option(@"two"), nil),
            nil);
    assertThat([items flatten], hasItems(@"one", @"two", nil));
}

- (void)testFold {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items fold:@"" with:[Callables appendString]], equalTo(@"onetwothree"));
}

- (void)testHead {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items head], equalTo(@"one"));
}

- (void)testHeadOption {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items headOption], equalTo([Some some:@"one"]));
    assertThat([array(nil) headOption], equalTo([None none]));
}

- (void)testJoin {
    NSArray *join = [array(@"one", nil) join:array(@"two", @"three", nil)];
    assertThat(join, hasItems(@"one", @"two", @"three", nil));
}

- (void)testMap {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items map:[Callables toUpperCase]], hasItems(@"ONE", @"TWO", @"THREE", nil));
}

-(void)testPartition {
    NSArray *items = array(@"one", @"two", @"three", @"four", nil);
    Pair *partitioned = [items partition:TL_alternate(TRUE)];
    assertThat(partitioned.left, hasItems(@"one", @"three", nil));
    assertThat(partitioned.right, hasItems(@"two", @"four", nil));
}

- (void)testReduce {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items reduce:[Callables appendString]], equalTo(@"onetwothree"));
}

-(void)testReverse {
    NSArray *items = array(@"one", @"two", @"three", nil);
    assertThat([items reverse], hasItems(@"three", @"two", @"one", nil));
}

-(void)testSplitOn {
    NSArray *items = array(@"one", @"two", @"three", @"four", nil);

    assertThat([items splitWhen:TL_equalTo(@"three")].left, hasItems(@"one", @"two", nil));
    assertThat([items splitWhen:TL_equalTo(@"three")].right, hasItems(@"four", nil));

    assertThat([items splitWhen:TL_equalTo(@"one")].left, isEmpty());
    assertThat([items splitWhen:TL_equalTo(@"four")].right, isEmpty());
}

- (void)testTail {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items tail], hasItems(@"two", @"three", nil));
}

- (void)testTake {
    NSArray *items = [array(@"one", @"two", @"three", nil) asArray];
    assertThat([items take:2], hasItems(@"one", @"two", nil));
    assertThat([items take:0], isEmpty());
}

- (void)testTakeWhile {
    NSArray *items = [array([NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil) asArray];
    assertThat(
        [items takeWhile:^(NSNumber *number) { return (BOOL)(number.intValue < 2); }],
        equalTo([array([NSNumber numberWithInt:1], nil) asArray])
    );
}

- (void)testTakeRight {
    NSArray *items = array(@"one", @"two", @"three", nil);
    assertThat([items takeRight:2], equalTo(array(@"two", @"three", nil)));
    assertThat([items takeRight:0], isEmpty());
    assertThat([items takeRight:10], equalTo(array(@"one", @"two", @"three", nil)));
}

-(void)testToString {
    NSArray *items = array(@"one", @"two", @"three", nil);
    assertThat([items toString], equalTo(@"onetwothree"));
    assertThat([items toString:@","], equalTo(@"one,two,three"));
    assertThat([items toString:@"(" separator:@"," end:@")"], equalTo(@"(one,two,three)"));
    
    NSArray *numbers = array(@(1), @(2), @(3), nil);
    assertThat([numbers toString], equalTo(@"123"));
}

-(void)testZip {
    NSArray *items = array(@"one", @"two", nil);
    NSArray *zip = [items zip:array(@(1), @(2), nil)];
    assertThat(zip, hasItems([Pair left:@"one" right:@(1)], [Pair left:@"two" right:@(2)], nil));
}

-(void)testAsSet {
    NSArray *items = [array(@"one", @"two", @"two", nil) asArray];
    assertThat([items asSet], equalTo([array(@"one", @"two", nil) asSet]));
}

-(void)testAsDictionary {
    NSDictionary *actual = [array(@"key1", @"value1", @"key2", @"value2", @"key3", nil) asDictionary];
    assertThat(actual, equalTo([NSDictionary dictionaryWithObjects:array(@"value1", @"value2", nil)
                                                           forKeys:array(@"key1", @"key2", nil)]));
}

@end