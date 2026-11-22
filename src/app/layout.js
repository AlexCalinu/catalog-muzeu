import Link from 'next/link';
import './globals.css';

export const metadata = {
  title: 'Catalog Muzeu',
  description: 'Catalog digital al exponatelor, cu imagini și audio-ghid',
};

export default function RootLayout({ children }) {
  return (
    <html lang="ro">
      <body>
        <header className="antet">
          <div className="container antet-interior">
            <Link href="/" className="logo">Catalog Muzeu</Link>
            <nav>
              <Link href="/exponate">Exponate</Link>
              <Link href="/exponate/nou">Adaugă exponat</Link>
            </nav>
          </div>
        </header>
        <main className="container">{children}</main>
      </body>
    </html>
  );
}
