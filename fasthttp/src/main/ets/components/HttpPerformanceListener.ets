import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * HTTP性能侦听器
 */
export interface HttpPerformanceListener {
  // 输出性能
  onPerformance?: (timeInfo: rcp.TimeInfo) => void;
}