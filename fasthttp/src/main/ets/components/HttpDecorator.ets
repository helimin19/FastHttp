
export function GET(url: string) {
  return (target: Object, methodName: string) => {

    console.log("limin", url);

  }
}

export function Header(target: Object, methodName: string, parameterIndex: number) {
  console.log("limin", parameterIndex);
  // 创建一个属性来存储原方法
  const originalMethod = Reflect.get(target, methodName) as Function;

  console.log("limin", originalMethod);

  // 替换目标对象上的方法
  // Reflect.set(target, methodName, wrappedMethod);
}
