import Foundation
import Supabase

final class SupabaseVisitorRemoteDataSource: VisitorRemoteDataSource, @unchecked Sendable {
    private let client = SupabaseClientProvider.shared

    func upload(visitor: VisitorRecordDTO) async throws -> VisitorRecordDTO {
        let validRemoteId = validRemoteId(from: visitor.remoteId)
        let payload = SupabaseVisitorRecordRow(dto: visitor, remoteId: validRemoteId)

        let row: SupabaseVisitorRecordRow
        if let validRemoteId {
            row = try await client
                .from("visitor_records")
                .update(payload)
                .eq("id", value: validRemoteId)
                .select()
                .single()
                .execute()
                .value
        } else {
            row = try await client
                .from("visitor_records")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value
        }

        return row.dto
    }

    func fetchVisitorsChanged(
        since: Date?,
        forSiteId siteId: String,
        historyRetentionDays: Int
    ) async throws -> [VisitorRecordDTO] {
        let retentionCutoff = Calendar.current.date(byAdding: .day, value: -historyRetentionDays, to: Date()) ?? .distantPast

        let activeRows: [SupabaseVisitorRecordRow] = try await client
            .from("visitor_records")
            .select()
            .eq("site_id", value: siteId)
            .is("sign_out_time", value: nil)
            .is("deleted_at", value: nil)
            .order("updated_at", ascending: true)
            .execute()
            .value

        let historyRows: [SupabaseVisitorRecordRow]
        if let since {
            historyRows = try await client
                .from("visitor_records")
                .select()
                .eq("site_id", value: siteId)
                .is("deleted_at", value: nil)
                .not("sign_out_time", operator: .is, value: "null")
                .gte("sign_out_time", value: formattedTimestamp(retentionCutoff))
                .gt("updated_at", value: formattedTimestamp(since))
                .order("updated_at", ascending: true)
                .execute()
                .value
        } else {
            historyRows = try await client
                .from("visitor_records")
                .select()
                .eq("site_id", value: siteId)
                .is("deleted_at", value: nil)
                .not("sign_out_time", operator: .is, value: "null")
                .gte("sign_out_time", value: formattedTimestamp(retentionCutoff))
                .order("updated_at", ascending: true)
                .execute()
                .value
        }

        let mergedRows = Dictionary(
            uniqueKeysWithValues: (activeRows + historyRows).map { row in
                (row.id ?? UUID().uuidString, row)
            }
        )

        return mergedRows.values
            .sorted { $0.updatedAt < $1.updatedAt }
            .map { $0.dto }
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    private func validRemoteId(from remoteId: String?) -> String? {
        guard let remoteId else { return nil }

        let trimmedRemoteId = remoteId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedRemoteId.isEmpty,
            !trimmedRemoteId.hasPrefix("mock-"),
            UUID(uuidString: trimmedRemoteId) != nil
        else {
            return nil
        }

        return trimmedRemoteId
    }
}

private struct SupabaseVisitorRecordRow: Codable, Sendable {
    let id: String?
    let deviceId: String
    let siteId: String
    let siteName: String
    let fullName: String
    let company: String
    let phoneNumber: String
    let hostName: String
    let visitReason: String
    let signInTime: Date
    let signOutTime: Date?
    let safetyBriefingCompleted: Bool
    let escorted: Bool
    let notes: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case siteId = "site_id"
        case siteName = "site_name"
        case fullName = "full_name"
        case company
        case phoneNumber = "phone_number"
        case hostName = "host_name"
        case visitReason = "visit_reason"
        case signInTime = "sign_in_time"
        case signOutTime = "sign_out_time"
        case safetyBriefingCompleted = "safety_briefing_completed"
        case escorted
        case notes
        case latitude
        case longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    nonisolated init(dto: VisitorRecordDTO, remoteId: String?) {
        id = remoteId
        deviceId = dto.deviceId
        siteId = dto.siteId
        siteName = dto.siteName
        fullName = dto.fullName
        company = dto.company
        phoneNumber = dto.phoneNumber
        hostName = dto.hostName
        visitReason = dto.visitReason
        signInTime = dto.signInTime
        signOutTime = dto.signOutTime
        safetyBriefingCompleted = dto.safetyBriefingCompleted
        escorted = dto.escorted
        notes = dto.notes
        latitude = dto.latitude
        longitude = dto.longitude
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
        deletedAt = nil
    }

    nonisolated var dto: VisitorRecordDTO {
        VisitorRecordDTO(
            localId: UUID(),
            remoteId: id,
            siteId: siteId,
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            hostName: hostName,
            siteName: siteName,
            visitReason: visitReason,
            signInTime: signInTime,
            signOutTime: signOutTime,
            safetyBriefingCompleted: safetyBriefingCompleted,
            escorted: escorted,
            notes: notes,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: .synced,
            deviceId: deviceId
        )
    }
}
