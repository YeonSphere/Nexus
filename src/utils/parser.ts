import { URL } from 'url';

export class UrlParser {
  private url: URL;

  constructor(urlString: string) {
    this.url = new URL(urlString);
  }

  getProtocol(): string {
    return this.url.protocol.slice(0, -1); // Remove the trailing colon
  }

  getHostname(): string {
    return this.url.hostname;
  }

  getPath(): string {
    return this.url.pathname;
  }

  getQueryParams(): Record<string, string> {
    const params: Record<string, string> = {};
    this.url.searchParams.forEach((value, key) => {
      params[key] = value;
    });
    return params;
  }

  getFragment(): string {
    return this.url.hash.slice(1); // Remove the leading '#'
  }

  toString(): string {
    return this.url.toString();
  }
}
