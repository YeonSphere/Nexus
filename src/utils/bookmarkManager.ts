import { Bookmark } from '../types/bookmark';

export class BookmarkManager {
    private bookmarks: Bookmark[] = [];

    addBookmark(bookmark: Bookmark): void {
        this.bookmarks.push(bookmark);
    }

    removeBookmark(id: string): void {
        this.bookmarks = this.bookmarks.filter(bookmark => bookmark.id !== id);
    }

    getBookmarks(): Bookmark[] {
        return this.bookmarks;
    }

    getBookmarkById(id: string): Bookmark | undefined {
        return this.bookmarks.find(bookmark => bookmark.id === id);
    }

    updateBookmark(id: string, updatedBookmark: Partial<Bookmark>): void {
        const index = this.bookmarks.findIndex(bookmark => bookmark.id === id);
        if (index !== -1) {
            this.bookmarks[index] = { ...this.bookmarks[index], ...updatedBookmark };
        }
    }
}
