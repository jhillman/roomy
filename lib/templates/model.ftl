package ${packageName}.model<#if package??>.${package}</#if>;

<#if primaryKeyMember??>
import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.Ignore;
import android.arch.persistence.room.PrimaryKey;
</#if>
import android.arch.persistence.room.Embedded;
<#if parcelable>

import android.os.Parcel;
import android.os.Parcelable;
</#if>
<#if gson>

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.google.gson.TypeAdapter;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;
import java.io.IOException;
import com.google.gson.GsonBuilder;
import ${packageName}.model.ModelAdapterFactory;
</#if>
<#if importLists>

import java.util.ArrayList;
import java.util.List;
</#if>
<#if importDate>

import java.util.Date;
</#if>

<#list enums + models as import>
import ${import};
</#list>

<#if baseClass??>
import ${baseClass};
</#if>

import org.json.JSONObject;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
  
<#if primaryKeyMember?? && !noTable>
@Entity(tableName="${name?lower_case}")
</#if>
public class ${name}<#if baseClassName??> extends ${baseClassName}</#if><#if parcelable> implements Parcelable</#if> {
<#list members as member>
    <#if member.primaryKey>
    @PrimaryKey
    </#if>
    <#if member.ignored>
    @Ignore
    <#elseif primaryKeyMember??>
    @ColumnInfo(name="${member.name}")
    </#if>
    <#if member.serializedName??>
    @SerializedName("${member.serializedName!member.name}")
    </#if>
    private<#if member.noGson??> transient</#if> ${member.memberType} m${member.memberName?cap_first};
</#list>

    public ${name}() {}
<#list constructors as constructor>

    <#if primaryKeyMember?? && !noTable>
    @Ignore
    </#if>
    public ${name}(${constructor.members[0].memberType} ${constructor.members[0].memberName}<#list constructor.members[1..] as member>, ${member.memberType} ${member.memberName}</#list>) {
<#list constructor.members as member>
        m${member.memberName?cap_first} = ${member.memberName};
</#list>
    }
</#list>
<#if parcelable>

    <#if primaryKeyMember?? && !noTable>
    @Ignore
    </#if>
    public ${name}(Parcel parcel) {
<#if baseClassName??>
        super(parcel);

</#if>
<#list members as member>
<#if member.type == "boolean">
        m${member.memberName?cap_first} = parcel.readInt() == 1;
<#elseif member.type == "enum">

        String ${member.memberName}String = parcel.readString();
        if (${member.memberName}String != null) {
            m${member.memberName?cap_first} = ${enumMap[member.class]}.valueOf(${member.memberName}String); 
        }

<#elseif member.type == "byte[]">

        int ${member.memberName}Length = parcel.readInt();
        if (${member.memberName}Length >= 0) {
            byte[] ${member.memberName} = new byte[${member.memberName}Length];
            parcel.readByteArray(${member.memberName});
            m${member.memberName?cap_first} = ${member.memberName}; 
        }

<#elseif member.type == "Date">

        long ${member.memberName}Time = parcel.readLong();
        if (${member.memberName}Time >= 0) {
            m${member.memberName?cap_first} = new Date(${member.memberName}Time);
        }

<#elseif member.type == "class">
    <#if member.parcelable??>
        m${member.memberName?cap_first} = parcel.readParcelable(${modelMap[member.name + member.class]}.class.getClassLoader());
    <#elseif member.serializable??>
        m${member.memberName?cap_first} = (${modelMap[member.name + member.class]}) parcel.readSerializable();
    </#if>
<#elseif member.type == "class[]">
    <#if member.parcelable??>
        m${member.memberName?cap_first} = parcel.createTypedArrayList(${modelNameMap[member.class]}.CREATOR);
    <#elseif member.serializable??>

        int ${member.memberName}Count = parcel.readInt();
        if (${member.memberName}Count >= 0) {
            ${modelMap[member.name + member.class]} ${member.memberName} = new Array${modelMap[member.name + member.class]}();
            
            for (int i = 0; i < ${member.memberName}Count; i++) {
                ${member.memberName}.add((${modelNameMap[member.class]})parcel.readSerializable());
            }

            m${member.memberName?cap_first} = ${member.memberName};
        }

    </#if>
<#else>
        m${member.memberName?cap_first} = parcel.read${member.type?cap_first}(); 
</#if>
</#list>
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) { 
<#if baseClassName??>
        super(parcel);
</#if>
<#list members as member>
<#if member.type == "boolean">
        parcel.writeInt(m${member.memberName?cap_first} ? 1 : 0); 
<#elseif member.type == "enum">
        parcel.writeString(m${member.memberName?cap_first} != null ? m${member.memberName?cap_first}.name() : null); 
<#elseif member.type == "byte[]">

        if (m${member.memberName?cap_first} != null) {
            parcel.writeInt(m${member.memberName?cap_first}.length);
            parcel.writeByteArray(m${member.memberName?cap_first}); 
        } else {
            parcel.writeInt(-1);
        }

<#elseif member.type == "Date">

        if (m${member.memberName?cap_first} != null) {
            parcel.writeLong(m${member.memberName?cap_first}.getTime());
        } else {
            parcel.writeInt(-1);
        }

<#elseif member.type == "class">
    <#if member.parcelable??>
        parcel.writeParcelable(m${member.memberName?cap_first}, flags);
    <#elseif member.serializable??>
        parcel.writeSerializable(m${member.memberName?cap_first});
    </#if>
<#elseif member.type == "class[]">
    <#if member.parcelable??>
        parcel.writeTypedList(m${member.memberName?cap_first});
    <#elseif member.serializable??>

        if (m${member.memberName?cap_first} == null) {
            parcel.writeInt(-1);
        } else {
            parcel.writeInt(m${member.memberName?cap_first}.size());
        
            for (Serializable serializable : m${member.memberName?cap_first}) {
                parcel.writeSerializable(serializable);
            }
        }

    </#if>
<#else>
        parcel.write${member.type?cap_first}(m${member.memberName?cap_first}); 
</#if>
</#list>
    }

    public static final Creator<${name}> CREATOR = new Creator<${name}>() {
        public ${name} createFromParcel(Parcel in) {
            return new ${name}(in);
        }

        public ${name}[] newArray(int size) {
            return new ${name}[size];
        }
    };
</#if>
<#list members as member>

    public ${member.memberType} get${member.memberName?cap_first}() {
        return m${member.memberName?cap_first};
    }

    public final void set${member.memberName?cap_first}(${member.memberType} ${member.memberName}) {
        m${member.memberName?cap_first} = ${member.memberName};
    }
</#list>

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
<#if gson && !noTypeAdapter>

    public static final class GsonTypeAdapter extends TypeAdapter<${name}> {
        <#list types as type>
        private final TypeAdapter<${type.type}> m${type.name}Adapter; 
        </#list>

        public GsonTypeAdapter(Gson gson) {
        <#list types as type>
             m${type.name}Adapter = gson.getAdapter(<#if type.isList>new TypeToken<${type.type}>(){}<#else>${type.name}.class</#if>);
        </#list>
        }

        @Override
        public ${name} read(JsonReader jsonReader) throws IOException {
            ${name} json${name} = null;

            if (jsonReader.peek() != JsonToken.NULL && jsonReader.peek() == JsonToken.BEGIN_OBJECT) {
                json${name} = new ${name}();

                jsonReader.beginObject();

                while (jsonReader.hasNext()) {
                    String name = jsonReader.nextName();

                    if (jsonReader.peek() == JsonToken.NULL) {
                        jsonReader.skipValue();
                        continue;
                    }
                
                    switch (name) {
                    <#list baseMembers + members as member>
                        <#if !member.noGson>
                        case "${member.serializedName!member.name}":
                            json${name}.set${member.memberName?cap_first}(m${member.adapterType}Adapter.read(jsonReader));
                            break;
                        </#if>
                    </#list>
                        default: {
                            jsonReader.skipValue();
                        }
                    }
                }

                jsonReader.endObject();
            }

            return json${name};
        }

        @Override
        public void write(JsonWriter jsonWriter, ${name} object) throws IOException {
            jsonWriter.beginObject();

    <#assign primitives = ['boolean', 'short', 'int', 'long', 'float', 'double']>
    <#list baseMembers + members as member>
        <#if !member.noGson>
            <#if primitives?seq_contains(member.type?lower_case)>
            jsonWriter.name("${member.serializedName!member.name}");
            m${member.adapterType}Adapter.write(jsonWriter, object.get${member.memberName?cap_first}());

            <#else> 
            if (object.get${member.memberName?cap_first}() != null) {
                jsonWriter.name("${member.serializedName!member.name}");
                m${member.adapterType}Adapter.write(jsonWriter, object.get${member.memberName?cap_first}());
            }
            
            </#if>
        </#if>
    </#list>     
            jsonWriter.endObject();
        }
    }
</#if>
}