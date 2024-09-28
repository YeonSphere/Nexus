declare module 'seokjin-ai' {
  export class SeokjinAI {
    processInput(input: string): Promise<string>;
    learnFromWeb(url: string): Promise<void>;
    loadContextFromFile(filePath: string): Promise<void>;
    getBatteryLevel(): Promise<number>;
  }
}
