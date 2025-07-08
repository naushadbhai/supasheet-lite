import { DefaultLayout } from "@/components/layouts/default-layout";
import { SidebarInset } from "@/components/ui/sidebar";
import { SqlSidebar } from "@/features/sql/components/sql-sidebar";

export default async function HomeSqlLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <DefaultLayout>
      <SqlSidebar />
      <SidebarInset>
        <div className="w-full flex-1">{children}</div>
      </SidebarInset>
    </DefaultLayout>
  );
}
