
/**
 * 调试侦听器
 */
export interface HttpDebugListener {

  onRequestHeader: (context: string) => void;
  onRequestBody: (context: string) => void;
  onResponseHeader: (context: string) => void;
  onResponseBody: (context: string) => void;
  onSslIn: (context: ArrayBuffer) => void;
  onSslOut: (context: ArrayBuffer) => void;
  onText: (context: string) => void;

}