// import { SquarePenIcon, TrashIcon } from "lucide-react";
// import { Button } from "@/components/ui/button";
import { notFound } from "next/navigation";

import { ResourceDetailView } from "@/features/resources/components/view/resource-detail-view";
import { ResourceForiegnDataView } from "@/features/resources/components/view/resource-foriegn-data-view";
import { ResourceMetadataView } from "@/features/resources/components/view/resource-metadata-view";
import {
  loadColumnsSchema,
  loadSingleResourceData,
  loadTableSchema,
} from "@/features/resources/lib/loaders";
import { DatabaseTables, PrimaryKey } from "@/lib/database-meta.types";

export default async function ViewPage({
  params,
}: {
  params: Promise<{
    id: string;
    pk: string[];
  }>;
}) {
  const { id, pk } = await params;
  const tableSchema = await loadTableSchema(id);
  if (!tableSchema) return notFound();

  const columnsSchema = await loadColumnsSchema(id);
  if (!columnsSchema) return notFound();

  const primaryKeys = tableSchema?.primary_keys as PrimaryKey[];

  const singleResourceData = await loadSingleResourceData(
    id as DatabaseTables,
    primaryKeys.reduce(
      (acc, key, index) => {
        acc[key.name] = pk[index];
        return acc;
      },
      {} as Record<string, unknown>,
    ),
  );
  if (!singleResourceData) return notFound();

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="flex flex-col gap-2.5">
        <div className="pt-10 pb-4 text-xl font-medium">View {id}</div>
        <div>
          <div className="space-y-2.5">
            {/* Resource Details */}
            <ResourceDetailView
              columnsSchema={columnsSchema ?? []}
              singleResourceData={singleResourceData ?? {}}
            />

            {/* Metadata */}
            <ResourceMetadataView
              columnsSchema={columnsSchema ?? []}
              singleResourceData={singleResourceData ?? {}}
            />

            {/* Foreign Key Data */}
            <ResourceForiegnDataView
              tableSchema={tableSchema}
              singleResourceData={singleResourceData ?? {}}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
