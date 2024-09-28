import { SeokjinAI } from 'seokjin-ai';

export class SeokjinAIIntegration {
    private ai: SeokjinAI;

    constructor() {
        this.ai = new SeokjinAI();
    }

    public async processInput(input: string): Promise<string> {
        try {
            return await this.ai.processInput(input);
        } catch (error) {
            console.error('Error processing input:', error);
            return 'Sorry, I encountered an error while processing your request.';
        }
    }

    public async learnFromCurrentPage(url: string): Promise<void> {
        try {
            await this.ai.learnFromWeb(url);
        } catch (error) {
            console.error('Error learning from web:', error);
        }
    }

    public async loadContextFromFile(filePath: string): Promise<void> {
        try {
            await this.ai.loadContextFromFile(filePath);
        } catch (error) {
            console.error('Error loading context from file:', error);
        }
    }

    public async getBatteryLevel(): Promise<number> {
        try {
            return await this.ai.getBatteryLevel();
        } catch (error) {
            console.error('Error getting battery level:', error);
            return -1;
        }
    }
}
