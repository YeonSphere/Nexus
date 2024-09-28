declare module 'node-fetch' {
  export class Request extends globalThis.Request {}
  export class Response extends globalThis.Response {}
  export class Headers extends globalThis.Headers {}
  export class Blob extends globalThis.Blob {}
  export class FormData extends globalThis.FormData {}
  export type RequestInfo = string | Request;
  export type RequestInit = globalThis.RequestInit;

  function fetch(url: RequestInfo, init?: RequestInit): Promise<Response>;
  export default fetch;
}
