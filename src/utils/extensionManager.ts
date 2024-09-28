import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export class ExtensionManager {
    private static instance: ExtensionManager;
    private extensions: Map<string, vscode.Extension<any>>;

    private constructor() {
        this.extensions = new Map();
    }

    public static getInstance(): ExtensionManager {
        if (!ExtensionManager.instance) {
            ExtensionManager.instance = new ExtensionManager();
        }
        return ExtensionManager.instance;
    }

    public loadExtensions(context: vscode.ExtensionContext): void {
        const extensionsPath = path.join(context.extensionPath, 'extensions');
        if (fs.existsSync(extensionsPath)) {
            const files = fs.readdirSync(extensionsPath);
            for (const file of files) {
                if (file.endsWith('.js')) {
                    const extensionPath = path.join(extensionsPath, file);
                    const extension = require(extensionPath);
                    if (extension.activate) {
                        const disposable = extension.activate(context);
                        if (disposable) {
                            context.subscriptions.push(disposable);
                            this.extensions.set(file, extension);
                        }
                    }
                }
            }
        }
    }

    public getExtension(name: string): vscode.Extension<any> | undefined {
        return this.extensions.get(name);
    }

    public getAllExtensions(): Map<string, vscode.Extension<any>> {
        return this.extensions;
    }
}
