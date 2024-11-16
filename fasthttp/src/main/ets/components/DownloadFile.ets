import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * HTTP下载文件
 */
export interface DownloadFile {
  response: rcp.Response,
  filePath?: string
}